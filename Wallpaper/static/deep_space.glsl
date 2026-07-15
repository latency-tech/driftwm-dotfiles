// Generated Gradient Shader
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform float alpha;
uniform vec2 u_camera;
uniform float u_time;

void main() {
    vec2 uv = v_coords;
    vec3 color1 = vec3(0.08, 0.10, 0.20);
    vec3 color2 = vec3(0.25, 0.10, 0.45);
    
    float t = uv.y + sin(uv.x * 3.14159 * 3.50 + u_time * 0.15) * 0.1;
    vec3 color = mix(color1, color2, t);
    
    float vignette = 1.0 - length(uv - 0.5) * 0.5;
    color *= vignette;
    color += vec3(0.05);
    
    gl_FragColor = vec4(color, 1.0) * alpha;
}
