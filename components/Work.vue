<script setup>
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import { work } from '~/data/work'

// The list is rendered twice and the scroll position wraps from the second
// copy back to the first, so the work scrolls forever.
const copies = ['a', 'b']

// At most this many videos are mounted at once; the least recently seen
// one is unmounted when another scrolls into view.
const MAX_LOADED = 3

const isVisible = ref(false)
const hasAnimated = ref(false)
const workScroll = ref(null)
const secondSet = ref(null)
const useBgVideo = ref(false)

const loadedVideos = ref(new Set())
let videoLRU = []
const players = {} // videoKey -> { main, bg }

const slideIndices = reactive(Object.fromEntries(
    work.map((item, i) => [i, 0]).filter(([i]) => work[i].slider),
))

let inviewObserver = null
let videoObserver = null
let sliderInterval = null

// Background video only when the connection is quick and the visitor
// hasn't asked to save data. Desktop browsers without the API count as fast.
const hasFastConnection = () => {
    const conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection
    if (!conn) return true
    if (conn.saveData) return false
    return conn.effectiveType === '4g' || conn.downlink > 5
}

// The second copy's top edge is where the scroll loops back.
const setWorkSet = (copy, el) => {
    if (copy === 'b') secondSet.value = el
}

const setPlayer = (key, slot, el) => {
    players[key] ??= {}
    players[key][slot] = el
}

const eachPlayer = (key, fn) => {
    const p = players[key]
    if (!p) return
    if (p.main) fn(p.main)
    if (p.bg) fn(p.bg)
}

const loadVideo = (key) => {
    videoLRU = videoLRU.filter(k => k !== key)
    videoLRU.push(key)
    if (loadedVideos.value.has(key)) return

    const next = new Set(loadedVideos.value).add(key)
    while (videoLRU.length > MAX_LOADED) {
        const oldest = videoLRU.shift()
        next.delete(oldest)
        delete players[oldest]
    }
    loadedVideos.value = next
}

const handleScroll = () => {
    const container = workScroll.value
    if (!container || !secondSet.value) return
    const loopPoint = secondSet.value.offsetTop
    if (container.scrollTop >= loopPoint) container.scrollTop -= loopPoint
}

const setupObservers = () => {
    inviewObserver = new IntersectionObserver((entries) => {
        for (const entry of entries) {
            if (entry.isIntersecting) entry.target.classList.add('is-inview')
        }
    }, { rootMargin: '50px', threshold: 0.01 })

    videoObserver = new IntersectionObserver((entries) => {
        for (const entry of entries) {
            const key = entry.target.dataset.videoKey
            if (!key) continue
            if (entry.isIntersecting) {
                loadVideo(key)
                // Muted, inline video is allowed to autoplay on mobile.
                nextTick(() => eachPlayer(key, p => p.play().catch(() => {})))
            } else {
                eachPlayer(key, p => p.pause())
            }
        }
    }, { rootMargin: '100px', threshold: 0.3 })

    workScroll.value.querySelectorAll('.work-item-image').forEach(el => inviewObserver.observe(el))
    workScroll.value.querySelectorAll('.video-container').forEach(el => videoObserver.observe(el))
}

onMounted(() => {
    useBgVideo.value = hasFastConnection()
    workScroll.value?.addEventListener('scroll', handleScroll, { passive: true })

    setTimeout(() => { isVisible.value = true }, 500)
    // Once the entrance animation has run, drop the transition so looping is seamless.
    setTimeout(() => { hasAnimated.value = true }, 1800)

    if (workScroll.value) nextTick(setupObservers)

    if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        sliderInterval = setInterval(() => {
            for (const i in slideIndices) {
                slideIndices[i] = (slideIndices[i] + 1) % work[i].slider.length
            }
        }, 1000)
    }
})

onUnmounted(() => {
    workScroll.value?.removeEventListener('scroll', handleScroll)
    inviewObserver?.disconnect()
    videoObserver?.disconnect()
    clearInterval(sliderInterval)
})
</script>

<template>
    <div class="work">
        <div ref="workScroll" class="work-scroll" :class="{ 'is-visible': isVisible, 'has-animated': hasAnimated }">
            <div
                v-for="copy in copies"
                :key="copy"
                :ref="el => setWorkSet(copy, el)"
                class="work-set"
            >
                <WorkItem
                    v-for="(item, index) in work"
                    :key="`${copy}-${index}`"
                    :item="item"
                    :video-key="`${copy}-${index}`"
                    :video-loaded="loadedVideos.has(`${copy}-${index}`)"
                    :use-bg-video="useBgVideo"
                    :slide-index="slideIndices[index] ?? 0"
                    :set-player="setPlayer"
                />
            </div>
        </div>
    </div>
</template>
