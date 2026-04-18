shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

group_uniforms Shape;
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform int layers = 20;
uniform float depth_scale : hint_range(0.01, 1) = 0.2;
uniform float depth_strength : hint_range(0.0,1.0) = 0.4;

group_uniforms Detail;
uniform sampler2D detail_noise_texture : filter_linear_mipmap, repeat_enable;
uniform float shape_detail_mix_factor : hint_range(0.0,1.0) = 0.4;
uniform vec2 detail_scale = vec2(4.0, 4.0);

group_uniforms Colour;
uniform vec3 highlight_color : source_color = vec3(0.576, 0.757, 0.424);
uniform vec3 base_color : source_color = vec3(0.341, 0.569, 0.282);

group_uniforms Colour.colour_variation;
uniform float mix_amount : hint_range(0.0,1.0) = 0.0;
uniform sampler2D colour_noise_texture : filter_linear_mipmap, repeat_enable;

group_uniforms Wind;
uniform float wind_strength : hint_range(0.0, 0.1) = 0.02;
uniform float wind_speed : hint_range(0.0, 10.0) = 2.0;
uniform vec2 wind_direction = vec2(1.0, 0.3);
uniform float wind_turbulence : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	// --- Wind offset ---
	// Нормализуем направление
	vec2 wind_dir = normalize(wind_direction);

	// Базовая синусоидальная волна ветра
	float wind_wave = sin(TIME * wind_speed + UV.x * 5.0 + UV.y * 3.0) * wind_strength;

	// Вторая гармоника для турбулентности
	float wind_turb = sin(TIME * wind_speed * 1.7 + UV.x * 9.0 - UV.y * 6.0)
	                  * wind_strength * wind_turbulence;

	vec2 wind_offset = wind_dir * (wind_wave + wind_turb);

	// --- Parallax setup ---
	float tangent  = dot(VIEW, TANGENT);
	float binormal = dot(-VIEW, BINORMAL);
	float normal   = dot(VIEW, NORMAL);

	float inv_layers = 1.0 / float(layers);

	vec2 uv_offset_total = (vec2(tangent, binormal) / normal) * depth_scale * 0.05;
	vec2 uv_step = uv_offset_total * inv_layers;

	// Ветер применяется сильнее на верхних слоях (кончики травы качаются больше)
	vec2 current_uv = UV + wind_offset;

	vec3 final_albedo = base_color;

	float base_threshold = depth_strength + 0.3;
	float detail_weight  = 1.0 - shape_detail_mix_factor;

	for (int i = 0; i < layers; i++) {
		float depth_ratio = float(i) * inv_layers;

		// Ветер ослабевает к корням: верхние слои (малый i) качаются сильнее
		float layer_wind_factor = 1.0 - depth_ratio;
		vec2 layer_uv = current_uv - wind_offset * (1.0 - layer_wind_factor);

		float base_noise   = texture(noise_texture,        layer_uv).x;
		float detail_noise = texture(detail_noise_texture, layer_uv * detail_scale).x;

		float combined_noise = mix(base_noise, detail_noise, detail_weight);
		float threshold      = base_threshold * (1.0 - depth_ratio);

		vec3 final_colour = mix(highlight_color,
		                        texture(colour_noise_texture, UV).rgb,
		                        mix_amount);

		if (combined_noise > threshold) {
			final_albedo = mix(final_colour, base_color, depth_ratio);
			break;
		}

		current_uv -= uv_step;
	}

	ALBEDO   = final_albedo;
	ROUGHNESS = 0.9;
	SPECULAR  = 0.05;
}