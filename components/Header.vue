<script setup>
import { inject, computed } from 'vue'

const currentView = inject('currentView')
const showInfo = inject('showInfo')
const showWork = inject('showWork')

const isInfoView = computed(() => currentView.value === 'info')
</script>

<template>
    <header>
        <h1>Research and Destroy</h1>
        <p v-if="!isInfoView" @click="showInfo" class="header-nav">Info</p>
        <p v-else @click="showWork" class="header-nav">Work</p>
    </header>
</template>
