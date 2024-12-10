shader_type spatial;

uniform vec4 grass_base_color = vec4(0.0, 0.3, 0.0, 1.0); // Dark green
uniform vec4 grass_tip_color = vec4(0.2, 0.4, 0.2, 1.0); // Lighter green
uniform float noise_scale = 0.1; // Lower scale for larger noise patterns
uniform float color_mix_ratio = 0.025; // Controls the mix between base and tip colors

// Simple noise function for smoother transitions
float smoothNoise(vec2 uv) {
    // Scale the UV coordinates
    vec2 scaledUV = uv * noise_scale;
    // Generate a smoother noise pattern
    float noise = fract(sin(dot(scaledUV, vec2(12.9898, 78.233))) * 43758.5453);
    return noise;
}

void fragment() {
    // Generate noise with smoother transitions
    float noise = smoothNoise(UV);

    // Interpolate noise with color_mix_ratio for a more controlled transition
    float mixFactor = mix(noise, color_mix_ratio, noise);

    // Create a mix of the base and tip colors based on adjusted noise value
    vec4 colorVariation = mix(grass_base_color, grass_tip_color, smoothstep(0.0, 1.0, mixFactor));

    // Output the final color
    ALBEDO = colorVariation.rgb;
    ALPHA = colorVariation.a;
}