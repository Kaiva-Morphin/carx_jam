shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    // Чем больше blur_strength — тем более "размытый" mip level
    float lod = strength;
    vec3 col = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod).rgb;
    COLOR = vec4(col, 1.0);
}