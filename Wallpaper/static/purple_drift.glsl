// Generated Gradient Shader
precision highp float;

varying vec2 v_coords;
uniform vec2 size;
uniform float alpha;
uniform vec2 u_camera;
uniform float u_time;

void main() {
    vec2 uv = v_coords;
    vec3 color1 = vec3(0.48, 0.20, 0.82);
    vec3 color2 = vec3(0.18, 0.12, 0.30);
    
    float t = uv.y + sin(uv.x * 3.14159 * 2.20 + u_time * 0.40) * 0.1;
    vec3 color = mix(color1, color2, t);
    
    
    color += vec3(0.12);
    
    gl_FragColor = vec4(color, 1.0) * alpha;
}
