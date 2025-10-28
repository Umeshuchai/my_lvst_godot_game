shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Blur parameters
uniform float blur_size : hint_range(0.0, 10.0) = 2.0;
uniform int blur_samples : hint_range(1, 8) = 1;

void fragment() {
    vec4 sum = vec4(0.0);
    vec2 uv = SCREEN_UV;

    // Compute number of samples correctly
    int total_samples = 0;

    for (int x = -blur_samples; x <= blur_samples; x++) {
        for (int y = -blur_samples; y <= blur_samples; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_size * SCREEN_PIXEL_SIZE;
            sum += texture(SCREEN_TEXTURE, uv + offset);
            total_samples++;
        }
    }

    // Average properly to maintain brightness
    COLOR = sum / float(total_samples);

    // Optional: ensure brightness consistency in gamma space
    COLOR.rgb = pow(COLOR.rgb, vec3(1.0/1.1)); // Uncomment if you work in linear space
}
