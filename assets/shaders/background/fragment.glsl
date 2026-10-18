precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uColorLight;
uniform vec3 uColorAccent;

varying vec2 vUv;

// Convert RGB to HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Simplex noise for organic variation
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                        -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m; m = m*m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Film grain noise
float grain(vec2 uv, float time) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233)) + time) * 43758.5453);
}

// Apply iridescent/holographic effect to a color
vec3 applyIridescence(vec3 color, vec2 uv, float time) {
    // Create flowing noise pattern
    float noise1 = snoise(uv * 2.0 + time * 0.15);
    float noise2 = snoise(uv * 3.0 - time * 0.1 + 100.0);
    float noise3 = snoise(uv * 1.5 + time * 0.08 + vec2(noise1, noise2) * 0.5);

    // Combine noise layers for organic flow
    float flowNoise = (noise1 + noise2 * 0.5 + noise3 * 0.25) / 1.75;

    // Convert to HSV for hue shifting
    vec3 hsv = rgb2hsv(color);

    // Iridescent hue shift based on position and noise
    float hueShift = flowNoise * 0.15 + uv.x * 0.1 + uv.y * 0.05;
    hsv.x = fract(hsv.x + hueShift);

    // Boost saturation slightly for more vivid colors
    hsv.y = min(hsv.y * 1.2, 1.0);

    // Add subtle brightness variation
    hsv.z *= 0.9 + flowNoise * 0.15;

    return hsv2rgb(hsv);
}

// Function to get color for a stack at a given local uv.y and animation time
vec3 getStackColor(float y, float t, vec3 c1, vec3 c2, vec3 c3, vec3 c4, vec3 c5) {
    float duration = 2.5;
    float stagger = 0.6;
    float minHeight = 0.01;
    float maxHeight = 0.80;
    float blurAmount = 0.25;

    // Animation progress for each layer
    float anim1 = clamp(t / duration, 0.0, 1.0);
    float anim2 = clamp((t - stagger) / duration, 0.0, 1.0);
    float anim3 = clamp((t - stagger * 2.0) / duration, 0.0, 1.0);
    float anim4 = clamp((t - stagger * 3.0) / duration, 0.0, 1.0);

    // Smooth easing
    anim1 = anim1 * anim1 * (3.0 - 2.0 * anim1);
    anim2 = anim2 * anim2 * (3.0 - 2.0 * anim2);
    anim3 = anim3 * anim3 * (3.0 - 2.0 * anim3);
    anim4 = anim4 * anim4 * (3.0 - 2.0 * anim4);

    // Calculate layer heights
    float h1 = mix(maxHeight, minHeight, anim1);
    float h2 = mix(minHeight, maxHeight, anim1) * (1.0 - anim2) + minHeight * anim2;
    float h3 = mix(minHeight, maxHeight, anim2) * (1.0 - anim3) + minHeight * anim3;
    float h4 = mix(minHeight, maxHeight, anim3) * (1.0 - anim4) + minHeight * anim4;
    float h5 = mix(minHeight, maxHeight, anim4);

    // Calculate cumulative positions (from bottom)
    float top1 = h1;
    float top2 = top1 + h2;
    float top3 = top2 + h3;
    float top4 = top3 + h4;

    // Blend between colors with smooth transitions
    vec3 color = c1;

    float blend1 = smoothstep(top1 - blurAmount, top1 + blurAmount, y);
    color = mix(c1, c2, blend1);

    float blend2 = smoothstep(top2 - blurAmount, top2 + blurAmount, y);
    color = mix(color, c3, blend2);

    float blend3 = smoothstep(top3 - blurAmount, top3 + blurAmount, y);
    color = mix(color, c4, blend3);

    float blend4 = smoothstep(top4 - blurAmount, top4 + blurAmount, y);
    color = mix(color, c5, blend4);

    return color;
}

void main() {
    vec2 uv = vUv;

    // Colors (bottom to top): green, orange, pink, red, blue
    vec3 green = vec3(0.0, 0.8, 0.2);
    vec3 orange = vec3(1.0, 0.5, 0.0);
    vec3 pink = vec3(1.0, 0.4, 0.7);
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);

    // Timing
    float duration = 2.5;
    float stagger = 0.6;
    float animDuration = stagger * 3.0 + duration;
    float transitionDuration = duration;
    float cycleDuration = animDuration + transitionDuration;

    float cycleTime = mod(uTime, cycleDuration);

    // Calculate transition progress
    float transitionStart = animDuration;
    float transitionProgress = clamp((cycleTime - transitionStart) / transitionDuration, 0.0, 1.0);
    transitionProgress = transitionProgress * transitionProgress * (3.0 - 2.0 * transitionProgress);

    // Offset for pushing stacks
    float offset = transitionProgress;

    // Current stack position (pushed down)
    float currentY = uv.y + offset;

    // New stack position (coming from top)
    float newY = uv.y + offset - 1.0;

    // Get colors from both stacks
    vec3 currentColor = getStackColor(currentY, min(cycleTime, animDuration), green, orange, pink, red, blue);
    vec3 newColor = getStackColor(newY, 0.0, green, orange, pink, red, blue);

    // Choose which stack to show based on position with soft blend
    float blurAmount = 0.25;
    float blendFactor = smoothstep(1.0 - blurAmount, 1.0 + blurAmount, currentY);
    vec3 color = mix(currentColor, newColor, blendFactor);

    // Apply iridescent/holographic effect
    color = applyIridescence(color, uv, uTime);

    // Add heavy film grain
    float grainAmount = 0.6;
    float grainSize = 0.1; // Lower = larger particles, Higher = finer grain

    // Multiple grain layers for rougher texture
    float grainNoise1 = grain(uv * uResolution * grainSize, uTime * 15.0);
    float grainNoise2 = grain(uv * uResolution * grainSize * 2.0, uTime * 23.0 + 100.0);
    float grainNoise3 = grain(uv * uResolution * grainSize * 0.5, uTime * 7.0 + 50.0);

    // Combine grains for more texture
    float combinedGrain = (grainNoise1 * 0.5 + grainNoise2 * 0.3 + grainNoise3 * 0.2);

    color += (combinedGrain - 0.5) * grainAmount;

    gl_FragColor = vec4(color, 1.0);
}
