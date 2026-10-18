import glsl from 'vite-plugin-glsl'

// Analytics only load when their IDs are set (on the live site), so local
// runs and forks don't report into them.
const gaId = process.env.NUXT_PUBLIC_GA_ID
const clarityId = process.env.NUXT_PUBLIC_CLARITY_ID

const analyticsScripts = [
  ...(gaId ? [
    { src: `https://www.googletagmanager.com/gtag/js?id=${gaId}`, async: true },
    {
      innerHTML: `
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', '${gaId}');
      `,
    },
  ] : []),
  ...(clarityId ? [
    {
      innerHTML: `
        (function(c,l,a,r,i,t,y){
          c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
          t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
          y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
        })(window, document, "clarity", "script", "${clarityId}");
      `,
    },
  ] : []),
]

export default defineNuxtConfig({
  compatibilityDate: '2025-12-12',
  css: ["@/assets/scss/main.scss"],
  vue: {
    compilerOptions: {
      isCustomElement: (tag) => tag.startsWith('mux-')
    }
  },
  app: {
    head: {
      meta: [
        { property: 'og:image', content: '/og-image.png' },
        { property: 'og:image:width', content: '1200' },
        { property: 'og:image:height', content: '630' },
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:image', content: '/og-image.png' },
      ],
      script: analyticsScripts,
    },
  },
  vite: {
    plugins: [glsl()],
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: (source, filename) => {
            if (filename.includes('main.scss')) return source;
            return `@use "@/assets/scss/_variables.scss" as *;\n${source}`;
          },
        },
      },
    },
  },
  modules: [
    "@nuxtjs/tailwindcss",
    "@nuxt/image",
  ],
  image: {
    provider: 'none',
  },
  nitro: {
    prerender: {
      crawlLinks: true,
    },
  },
});
