<script setup>
import { muxPoster } from '~/data/work'

// One piece of work: a video, an image slider or a still image.
// Work.vue decides when a video is loaded; this component just renders it.
const props = defineProps({
    item: { type: Object, required: true },
    // Unique per rendered copy (Work renders the list twice to loop).
    videoKey: { type: String, required: true },
    videoLoaded: { type: Boolean, default: false },
    useBgVideo: { type: Boolean, default: false },
    slideIndex: { type: Number, default: 0 },
    setPlayer: { type: Function, required: true },
})

// Videos size themselves; stills and sliders reserve their aspect ratio.
const ratioStyle = props.item.video
    ? undefined
    : { paddingBottom: `${(props.item.height / props.item.width) * 100}%` }
</script>

<template>
    <div class="work-item">
        <div class="work-item-image inview-blur-fade" :style="ratioStyle">
            <div v-if="item.slider" class="slider-container">
                <NuxtImg
                    v-for="(slide, si) in item.slider"
                    :key="si"
                    :src="slide"
                    :alt="item.title"
                    class="slider-image"
                    :class="{ 'is-active': slideIndex === si }"
                    loading="lazy"
                />
            </div>

            <div
                v-else-if="item.video"
                class="video-container"
                :data-video-key="videoKey"
                :style="item.cropTop ? `--crop-top: ${item.cropTop}px` : undefined"
            >
                <!-- Blurred backdrop: low-res video on fast connections, a tiny poster otherwise -->
                <mux-player
                    v-if="useBgVideo && videoLoaded"
                    :ref="el => setPlayer(videoKey, 'bg', el)"
                    class="blur-bg-video"
                    :playback-id="item.video"
                    muted
                    loop
                    playsinline
                    preload="metadata"
                    disable-cookies
                    max-resolution="480p"
                />
                <img v-else class="blur-bg" :src="muxPoster(item.video, 100)" alt="" />

                <mux-player
                    v-if="videoLoaded"
                    :ref="el => setPlayer(videoKey, 'main', el)"
                    :playback-id="item.video"
                    :poster="muxPoster(item.video, 1200)"
                    muted
                    loop
                    playsinline
                    preload="metadata"
                    disable-cookies
                />
            </div>

            <NuxtImg v-else :src="item.src" :alt="item.title" loading="lazy" />
        </div>
        <p class="work-item-title">{{ item.title }}</p>
    </div>
</template>
