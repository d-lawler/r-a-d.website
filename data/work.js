// Selected work, in display order.
//
// Three kinds of item:
//   video:  a Mux playback ID (posters come from Mux's image API)
//   slider: a folder of numbered .webp images in public/projects/<folder>
//   src:    a single still image in public/placeholder
//
// width/height set the aspect ratio. cropTop trims black bars from the
// top of a video, in pixels.

const slides = (folder, count) =>
    Array.from({ length: count }, (_, i) => `/projects/${folder}/${String(i + 1).padStart(2, '0')}.webp`)

export const work = [
    { video: '8y8rRgJJOQtPPCNUIq31MrhCm9h5j02028DGCYNYgiI6I', title: 'Lola and Pani', width: 1200, height: 885 },
    { video: 'xYQ01Uat6fZzokfWsa3gEsJmTAkq02a2UbZlk9Z8fyyLU', title: 'Christopher Anderson. Design: Manual', width: 1200, height: 885, cropTop: 15 },
    { video: 'h4mlZfiW02MElEZWzbBn00M3EuDqH00XwsbNd2HJY01P7KM', title: 'Joshua Gordon', width: 1200, height: 885 },
    { slider: slides('birdonthewire', 7), title: 'Bird on the Wire', width: 2000, height: 2000 },
    { video: '8L01asubfcu8XlS8AMyX26vrAvyPRdqpbhlVLEcO33MM', title: '1014 Gallery', width: 1200, height: 885 },
    { video: 'eVB5KAIo8JTSAmUjZxhYkbqSJBGTrbwAWIGy8PUcOxE', title: 'The Wade Brothers. Design: Manual', width: 1200, height: 885 },
    { slider: slides('janu', 7), title: 'JANU. CD: Colville-Walker', width: 2000, height: 2000 },
    { video: 'Rd8HGm00evpn8hyq1GYQe1RY00dpiHMcEWjH01026ZgZG1M', title: 'Fat Hand', width: 1200, height: 885 },
    { video: 'fOExtsiuAv4ZK400TXcjC9pZb9KNSAF00N3MIkBKEgJew', title: 'BBMG', width: 1200, height: 915 },
    { slider: slides('keelin', 4), title: 'Keelin Coyle', width: 2000, height: 2000 },
    { video: 'Cg01c02b901NTs1F6qowdS5Wk8u6Y019WEUfDEAf643hHng', title: 'Joe Hart', width: 1200, height: 881 },
    { src: '/placeholder/rc.webp', title: 'Rappcats Store. Design: Best of Times', width: 1200, height: 819 },
    { video: '1W02by4828VIjcfrZow8CKjZRLasMZObdKAeHEs01xSC8', title: 'Maria Dimitrova. Design: Liam Morrow LTD', width: 1200, height: 884 },
    { slider: slides('lunch', 8), title: 'Lunch Money Life. The God Phone', width: 2000, height: 2000 },
    { video: 'U8Of6KIF25EHA1301jRPNmFpiZrW6028lYGS7rrAy73OI', title: 'Mark Gilligan', width: 1200, height: 840 },
    { src: '/placeholder/fa.webp', title: 'FMLY', width: 1200, height: 881 },
    { video: '6WmzrL960091uS2dRDSdp33fj9C2Su6kQlkH2iHPbm800', title: 'Mixcloud', width: 1200, height: 749 },
    { src: '/placeholder/sp.webp', title: 'SkatePal', width: 1200, height: 823 },
]

// The first image of each non-video item, preloaded while the splash shows.
export const preloadImages = work
    .filter(item => !item.video)
    .map(item => item.slider ? item.slider[0] : item.src)

export const muxPoster = (playbackId, width) =>
    `https://image.mux.com/${playbackId}/thumbnail.jpg?width=${width}`
