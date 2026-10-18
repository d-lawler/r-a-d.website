<script setup>
import { ref, onMounted, onUnmounted, provide } from 'vue'
import { preloadImages } from '~/data/work'

// First images of the work, preloaded during the splash. Videos use Mux
// posters, which load on their own.

const preloadAllImages = () => {
    return Promise.all(
        preloadImages.map(src => {
            return new Promise((resolve) => {
                const img = new Image()
                img.onload = resolve
                img.onerror = resolve
                img.src = src
            })
        })
    )
}

const showSplash = ref(true)
const headerVisible = ref(false)
const currentView = ref('work') // 'work' or 'info' - will be set to 'info' on mobile after mount
const appLoaded = ref(false)

// ASCII marquee title
const titleText = 'RESEARCH AND DESTROY · DESIGN AND TECHNOLOGY · '
let titleIndex = 0
let titleInterval = null

const startTitleMarquee = () => {
    titleInterval = setInterval(() => {
        document.title = titleText.slice(titleIndex) + titleText.slice(0, titleIndex)
        titleIndex = (titleIndex + 1) % titleText.length
    }, 150)
}

// Custom cursor
const cursorX = ref(0)
const cursorY = ref(0)
const isHovering = ref(false)

const updateCursorPosition = (e) => {
    cursorX.value = e.clientX
    cursorY.value = e.clientY
}

const handleMouseEnter = (e) => {
    const target = e.target
    if (target && target.matches && target.matches('a, button, [role="button"], input, textarea, select, .cursor-pointer')) {
        isHovering.value = true
    }
}

const handleMouseLeave = (e) => {
    const target = e.target
    if (target && target.matches && target.matches('a, button, [role="button"], input, textarea, select, .cursor-pointer')) {
        isHovering.value = false
    }
}

const showInfo = () => {
    currentView.value = 'info'
}

const showWork = () => {
    currentView.value = 'work'
}

provide('currentView', currentView)
provide('showInfo', showInfo)
provide('showWork', showWork)

onMounted(async () => {
    // Start title marquee
    startTitleMarquee()

    // Cursor events
    document.addEventListener('mousemove', updateCursorPosition)
    document.addEventListener('mouseenter', handleMouseEnter, true)
    document.addEventListener('mouseleave', handleMouseLeave, true)

    // Trigger load animation
    requestAnimationFrame(() => {
        appLoaded.value = true
    })

    // Hide the splash once the images are in, but show it for at least 2s.
    const imagesReady = preloadAllImages()
    const minSplashTime = new Promise(resolve => setTimeout(resolve, 2000))

    await Promise.all([minSplashTime, imagesReady])
    showSplash.value = false

    // Show header after splash fades out and work scrolls up
    setTimeout(() => {
        headerVisible.value = true
    }, 1500)
})

onUnmounted(() => {
    document.removeEventListener('mousemove', updateCursorPosition)
    document.removeEventListener('mouseenter', handleMouseEnter, true)
    document.removeEventListener('mouseleave', handleMouseLeave, true)
    if (titleInterval) clearInterval(titleInterval)
})
</script>

<template>
    <div class="app-wrapper">
        <div
            class="rad-content w-full md:max-w-[430px] md:max-h-[800px] bg-rad-dark text-rad-light flex flex-col load-blur-fade relative z-10"
            :class="{ 'loaded': appLoaded }"
        >
            <Header class="shrink-0 relative z-20 load-blur-fade" :class="{ 'loaded': headerVisible }" />
            <main class="flex-1 overflow-visible flex flex-col relative z-10">
                <Transition name="blur-fade" mode="out-in">
                    <Splash v-if="showSplash" class="flex-1 flex items-center justify-center" />
                    <Work v-else-if="currentView === 'work'" key="work" class="flex-1" />
                    <Info v-else-if="currentView === 'info'" key="info" />
                </Transition>
            </main>
            <Footer class="shrink-0 sticky bottom-0 z-0" />
        </div>
        <ClientOnly>
            <Background />
        </ClientOnly>
        <ClientOnly>
            <div
                class="custom-cursor fixed pointer-events-none z-50 w-4 h-4 -ml-2 -mt-2 rounded-full border border-rad-light transition-transform duration-150"
                :class="{ 'scale-150': isHovering }"
                :style="{ transform: `translate3d(${cursorX}px, ${cursorY}px, 0)` }"
            />
        </ClientOnly>
    </div>
</template>
