# Research and Destroy

Website for [Research and Destroy](https://r-a-d.website), a small creative studio focused on design and technology.

Built with [Nuxt](https://nuxt.com), [Three.js](https://threejs.org) and [Mux](https://www.mux.com).

## Things worth looking at

- **Shader background.** [`components/Background.vue`](components/Background.vue) renders a full-screen Three.js plane driven by a custom GLSL fragment shader ([`assets/shaders/background/`](assets/shaders/background/)): simplex noise and HSV colour shifts over time. Pixel ratio is capped at 2 to keep it cheap on high-density screens, and the Three.js objects sit in `shallowRef` so Vue doesn't make them reactive.
- **A live favicon.** Every 100ms the WebGL canvas is drawn, scaled and clipped to a circle, onto a 32px canvas, and that becomes the favicon. The tab icon is a tiny window onto the background.
- **Video that only costs what you watch.** Work streams from Mux (HLS) through `<mux-player>`. An `IntersectionObserver` loads each video when it scrolls into view, plays it muted and inline so it autoplays on mobile, and pauses it when it leaves. The blurred video behind each piece only plays on a fast connection; otherwise it's a blurred Mux thumbnail.
- **No tracking unless configured.** Analytics only load when their IDs are set in the environment, so local runs and forks report nothing.

## Running it

Needs a Storyblok access token for the content.

```sh
cp .env.example .env   # add STORYBLOK_TOKEN
yarn install
yarn dev               # http://localhost:3000
yarn generate          # static build
```

## Fonts

The site is set in Neue Haas Display and Items, used under their own licences. They aren't in this repo: `yarn build` and `yarn generate` fetch them from a private repo when `FONTS_TOKEN` is set, and otherwise the site builds with fallback fonts.

## Licence

There's no licence on this project, on purpose. The code is here to read and learn from. The client work shown (images, video and copy) belongs to the studios and people it was made for and isn't available for reuse, so all rights are reserved.
