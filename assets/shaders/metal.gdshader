/*
modified
MIT
https://godotshaders.com/shader/metal-mario-shader-gold-silver-with-custom-reflection/
*/

shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D env_texture;
uniform vec3 metal_color_gold = vec3(1.0, 0.843, 0.0);
uniform vec3 metal_color_silver = vec3(0.75, 0.75, 0.75);
uniform bool use_gold = true;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec3 metal_color = use_gold ? metal_color_gold : metal_color_silver;
    ALBEDO = metal_color;
    METALLIC = metallic;
    ROUGHNESS = roughness;

    // Направление отражения
    vec3 N = normalize(NORMAL);
    vec3 V = normalize(-VIEW);
    vec3 R = reflect(V, N);

    // Перевод в equirectangular UV
    float phi = atan(R.z, R.x);
    float theta = acos(clamp(R.y, -1.0, 1.0));

    vec2 env_uv = vec2(
        phi / (2.0 * PI) + 0.5,
        theta / PI
    );

    vec3 env_reflection = texture(env_texture, env_uv).rgb;

    EMISSION = env_reflection * 0.5;
}