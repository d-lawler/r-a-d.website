<script setup>
import { ref, shallowRef, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import backgroundVertexShader from '@/assets/shaders/background/vertex.glsl'
import backgroundFragmentShader from '@/assets/shaders/background/fragment.glsl'

const containerRef = ref(null)
const isReady = ref(false)

// Use shallowRef to avoid Vue reactivity on Three.js objects
const scene = shallowRef(null)
const camera = shallowRef(null)
const renderer = shallowRef(null)
const background = shallowRef(null)

// Animation state
let animationId = null
let startTime = Date.now()
let lastFaviconUpdate = 0
let reducedMotion = false
const faviconUpdateInterval = 100 // Update favicon every 100ms

// Favicon canvas for scaling
let faviconCanvas = null
let faviconCtx = null
let faviconLink = null

const initFavicon = () => {
    faviconCanvas = document.createElement('canvas')
    faviconCanvas.width = 32
    faviconCanvas.height = 32
    faviconCtx = faviconCanvas.getContext('2d')

    // Find or create favicon link
    faviconLink = document.querySelector('link[rel="icon"]')
    if (!faviconLink) {
        faviconLink = document.createElement('link')
        faviconLink.rel = 'icon'
        document.head.appendChild(faviconLink)
    }
}

const updateFavicon = () => {
    if (!renderer.value || !faviconCtx || !faviconLink) return

    const canvas = renderer.value.domElement

    // Skip if canvas has no dimensions
    if (!canvas.width || !canvas.height) return

    // Clear and set up circular clip
    faviconCtx.clearRect(0, 0, 32, 32)
    faviconCtx.save()
    faviconCtx.beginPath()
    faviconCtx.arc(16, 16, 16, 0, Math.PI * 2)
    faviconCtx.closePath()
    faviconCtx.clip()

    // Draw scaled version of the WebGL canvas to favicon canvas
    faviconCtx.drawImage(canvas, 0, 0, canvas.width, canvas.height, 0, 0, 32, 32)

    faviconCtx.restore()

    // Update favicon
    faviconLink.href = faviconCanvas.toDataURL('image/png')
}

const init = () => {
    if (!containerRef.value) return

    const container = containerRef.value
    const width = container.clientWidth
    const height = container.clientHeight

    scene.value = new THREE.Scene()

    camera.value = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10)
    camera.value.position.z = 1

    // Without WebGL (old devices, hardware acceleration off, screenshot
    // bots), skip the background rather than taking the whole page down.
    try {
        renderer.value = new THREE.WebGLRenderer({
            antialias: true,
            alpha: true,
            powerPreference: 'low-power'
        })
    } catch {
        return
    }
    renderer.value.setSize(width, height)
    renderer.value.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    renderer.value.setClearColor(0x000000, 0)
    container.appendChild(renderer.value.domElement)

    createBackground()
    initFavicon()

    isReady.value = true

    // With reduced motion, show a single still frame.
    if (reducedMotion) {
        lastFaviconUpdate = 0
        renderFrame()
    } else {
        animate()
    }
}

const createBackground = () => {
    const geometry = new THREE.PlaneGeometry(2, 2)

    const container = containerRef.value
    const material = new THREE.ShaderMaterial({
        vertexShader: backgroundVertexShader,
        fragmentShader: backgroundFragmentShader,
        uniforms: {
            uTime: { value: 0 },
            uResolution: { value: new THREE.Vector2(container.clientWidth, container.clientHeight) },
            uColorLight: { value: new THREE.Color(0xffffff) },
            uColorAccent: { value: new THREE.Color(0x00ff00) }
        }
    })

    background.value = new THREE.Mesh(geometry, material)
    scene.value.add(background.value)
}

// Draw one frame of the shader and, at most every faviconUpdateInterval,
// copy it into the favicon. The copy has to happen straight after the
// render, while WebGL's drawing buffer still holds the frame.
const renderFrame = () => {
    if (!renderer.value || !scene.value || !camera.value) return

    const now = Date.now()
    if (background.value && !reducedMotion) {
        background.value.material.uniforms.uTime.value = (now - startTime) / 1000
    }

    renderer.value.render(scene.value, camera.value)

    if (now - lastFaviconUpdate > faviconUpdateInterval) {
        updateFavicon()
        lastFaviconUpdate = now
    }
}

const animate = () => {
    animationId = requestAnimationFrame(animate)
    renderFrame()
}

// requestAnimationFrame stops in background tabs, which is exactly when the
// favicon is on show. While hidden, keep it moving on a timer instead
// (browsers throttle this to about once a second).
let hiddenTimer = null

const handleVisibility = () => {
    clearInterval(hiddenTimer)
    hiddenTimer = null
    if (document.hidden && !reducedMotion) {
        hiddenTimer = setInterval(renderFrame, 1000)
    }
}

const handleResize = () => {
    if (!containerRef.value || !renderer.value) return

    const width = containerRef.value.clientWidth
    const height = containerRef.value.clientHeight

    renderer.value.setSize(width, height)

    if (background.value) {
        background.value.material.uniforms.uResolution.value.set(width, height)
    }

    // Resizing clears the canvas; the animation loop redraws it, the still frame doesn't.
    if (reducedMotion) renderFrame()
}

const dispose = () => {
    if (animationId) {
        cancelAnimationFrame(animationId)
    }

    if (background.value) {
        background.value.geometry.dispose()
        background.value.material.dispose()
    }

    if (renderer.value) {
        renderer.value.dispose()
        if (containerRef.value && renderer.value.domElement) {
            containerRef.value.removeChild(renderer.value.domElement)
        }
    }
}

onMounted(() => {
    reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (containerRef.value) {
        init()
    }
    window.addEventListener('resize', handleResize)
    document.addEventListener('visibilitychange', handleVisibility)
})

onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
    document.removeEventListener('visibilitychange', handleVisibility)
    clearInterval(hiddenTimer)
    dispose()
})
</script>

<template>
    <div ref="containerRef" class="background-canvas"></div>
</template>
