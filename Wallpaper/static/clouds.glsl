// Generated Clouds Shader
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform float alpha;
uniform vec2 u_camera;
uniform float u_time;

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    vec2 a = hash2(i);
    vec2 b = hash2(i + vec2(1.0, 0.0));
    vec2 c = hash2(i + vec2(0.0, 1.0));
    vec2 d = hash2(i + vec2(1.0, 1.0));
    return mix(mix(a.x, b.x, f.x), mix(c.x, d.x, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
    for (int i = 0; i < 1; i++) {
        v += a * noise(p);
        p = rot * p * 2.0;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 canvas = (v_coords * size + u_camera) * (0.003 / 4.00);
    float time = u_time * 0.12 * 0.08;
    
    float wx = fbm(canvas + time * 0.05);
    float wy = fbm(canvas + vec2(5.2, 1.3));
    vec2 warped = canvas + vec2(wx, wy) * 0.8;
    
    float clouds = fbm(warped + time * 0.02);
    
    vec3 color1 = vec3(0.30, 0.32, 1.00);
    vec3 color2 = vec3(0.10, 0.12, 0.14);
    vec3 color = mix(color1, color2, clouds);
    
    vec2 uv = v_coords;
    
    color += vec3(0.02);
    
    gl_FragColor = vec4(color, 1.0) * alpha;
}
