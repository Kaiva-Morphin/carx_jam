shader_type spatial;
render_mode unshaded;

void vertex() {
	//Positions the post-processing quad in front of the camera
	POSITION = vec4(VERTEX.xy,1.0,1.0);
}

uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
uniform sampler2D SCREEN_TEXTURE : source_color, hint_screen_texture, repeat_disable, filter_nearest;

uniform float zNear = 0.05;
uniform float zFar = 100.0;

uniform bool enable_outline = false;
uniform vec3 outline_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float outline_thickness : hint_range(0.0, 50.0) = 10.0;
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.3;

uniform bool enable_color_limit = true;
uniform int color_levels : hint_range(2, 32) = 8;

uniform bool enable_color_palette = true;

// --- 12-цветная палитра (тёмная, с глубиной) ---
uniform vec4 color1  : source_color = vec4(0.45, 0.58, 0.52, 1.0);
uniform vec4 color2  : source_color = vec4(0.38, 0.52, 0.46, 1.0);
uniform vec4 color3  : source_color = vec4(0.32, 0.47, 0.41, 1.0);
uniform vec4 color4  : source_color = vec4(0.27, 0.42, 0.36, 1.0);
uniform vec4 color5  : source_color = vec4(0.22, 0.37, 0.31, 1.0);
uniform vec4 color6  : source_color = vec4(0.18, 0.32, 0.27, 1.0);
uniform vec4 color7  : source_color = vec4(0.14, 0.28, 0.23, 1.0);
uniform vec4 color8  : source_color = vec4(0.11, 0.24, 0.19, 1.0);
uniform vec4 color9  : source_color = vec4(0.08, 0.20, 0.16, 1.0);
uniform vec4 color10 : source_color = vec4(0.05, 0.16, 0.13, 1.0);
uniform vec4 color11 : source_color = vec4(0.03, 0.12, 0.09, 1.0);
uniform vec4 color12 : source_color = vec4(0.01, 0.08, 0.06, 1.0);

// Нуарный hue shift
uniform float hue_shift : hint_range(-1.0, 1.0) = -0.08;
uniform float saturation_boost : hint_range(0.0, 2.0) = 0.75;
uniform float contrast_boost : hint_range(0.5, 2.0) = 1.1;

uniform bool enable_dithering = true;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.3;

// Sobel kernels
const mat3 Gx = mat3(
	vec3(-1.0, -2.0, -1.0),
	vec3( 0.0,  0.0,  0.0),
	vec3( 1.0,  2.0,  1.0)
);
const mat3 Gy = mat3(
	vec3(-1.0, 0.0, 1.0),
	vec3(-2.0, 0.0, 2.0),
	vec3(-1.0, 0.0, 1.0)
);

// RGB -> HSV
vec3 rgb2hsv(vec3 c){
	vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(
		abs(q.z + (q.w - q.y) / (6.0 * d + e)),
		d / (q.x + e),
		q.x
	);
}

// HSV -> RGB
vec3 hsv2rgb(vec3 c){
	vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

// Нуарный фильтр с фиксом hue wrapping
vec3 noir_tone(vec3 col){
	vec3 hsv = rgb2hsv(col);
	hsv.x = fract(hsv.x + hue_shift);  // ← фикс: оборачиваем hue в [0,1]
	hsv.y = clamp(hsv.y * saturation_boost, 0.0, 1.0);
	hsv.z = pow(clamp(hsv.z, 0.0, 1.0), contrast_boost);
	return clamp(hsv2rgb(hsv), 0.0, 1.0);
}

// Линейная глубина из проективной
float linearize_depth(float d, float zNearr, float zFarr){
	return (2.0 * zNearr * zFarr) / (zFarr + zNearr - d * (zFarr - zNearr));
}

// Sobel на глубине с линейной коррекцией
float sobel_depth(in vec2 uv, in vec2 offset, mat4 inv_proj)
{
	float x = 0.0, y = 0.0;
	for (int r = 0; r < 3; r++) {
		for (int c = 0; c < 3; c++) {
			vec2 sample_uv = uv + offset * vec2(float(c-1), float(r-1));
			float d_raw = texture(DEPTH_TEXTURE, sample_uv).r;
			float d_lin = linearize_depth(d_raw, zNear, zFar);
			x += Gx[r][c] * d_lin;
			y += Gy[r][c] * d_lin;
		}
	}
	return sqrt(x*x + y*y);
}

float luminance(vec3 c){
	return dot(c, vec3(0.2125, 0.7154, 0.0721));
}

// Sobel на нормах (без линейзации, т.к. это векторы)
float sobel_normal(in vec2 uv, in vec2 offset)
{
	float x = 0.0, y = 0.0;
	for (int r = 0; r < 3; r++) {
		for (int c = 0; c < 3; c++) {
			vec2 sample_uv = uv + offset * vec2(float(c-1), float(r-1));
			float l = luminance(texture(NORMAL_TEXTURE, sample_uv).rgb);
			x += Gx[r][c] * l;
			y += Gy[r][c] * l;
		}
	}
	return sqrt(x*x + y*y);
}

// Постеризация с джиттером для сглаживания
float posterize(float v, int levels, float jitter){
	return (floor(v * float(levels) + jitter) + 0.5) / float(levels);
}

// Bayer dithering 4x4
float dither(vec2 p, float threshold){
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	float m[16] = float[](
		0.0/16.0, 8.0/16.0, 2.0/16.0, 10.0/16.0,
		12.0/16.0, 4.0/16.0, 14.0/16.0, 6.0/16.0,
		3.0/16.0, 11.0/16.0, 1.0/16.0, 9.0/16.0,
		15.0/16.0, 7.0/16.0, 13.0/16.0, 5.0/16.0
	);
	return m[x + y * 4];
}

// Поиск ближайшего цвета в палитре (с оптимизацией)
vec3 palette_lookup(vec3 col, vec3 palette[12]){
	vec3 best = palette[0];
	float best_d = 1e10;
	for(int i = 0; i < 12; i++){
		float d = distance(col, palette[i]);
		if(d < best_d){
			best_d = d;
			best = palette[i];
		}
	}
	return best;
}

void fragment(){
	// Палитра
	vec3 palette[12];
	palette[0]=color1.rgb;  palette[1]=color2.rgb;  palette[2]=color3.rgb;
	palette[3]=color4.rgb;  palette[4]=color5.rgb;  palette[5]=color6.rgb;
	palette[6]=color7.rgb;  palette[7]=color8.rgb;  palette[8]=color9.rgb;
	palette[9]=color10.rgb; palette[10]=color11.rgb; palette[11]=color12.rgb;

	// Базовый цвет
	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	col = noir_tone(col);

	// Постеризация + дитеринг (вместе для лучшего результата)
	if(enable_color_limit || enable_dithering){
		float jitter = enable_dithering ? dither(FRAGCOORD.xy, 0.0) * dither_strength : 0.0;
		if(enable_color_limit){
			col = vec3(
				posterize(col.r, color_levels, jitter),
				posterize(col.g, color_levels, jitter),
				posterize(col.b, color_levels, jitter)
			);
		}
	}

	// Палитра
	if(enable_color_palette){
		col = palette_lookup(col, palette);
	}

	// Финальный дитеринг (если не применён выше)
	if(enable_dithering && !enable_color_limit){
		float lum = luminance(col);
		float threshold = dither(FRAGCOORD.xy, 0.0);
		float bias = (lum - threshold) * dither_strength;
		col = clamp(col + bias, 0.0, 1.0);
	}

	// Контуры
	if(enable_outline){
		vec2 offset = outline_thickness / VIEWPORT_SIZE;
		float e_depth = sobel_depth(SCREEN_UV, offset, INV_PROJECTION_MATRIX);
		float e_normal = sobel_normal(SCREEN_UV, offset);
		
		// Нормализация и комбинирование краёв
		float edge = smoothstep(0.0, 1.0, 
			(outline_threshold * 2.0) * e_depth + 
			(outline_threshold) * e_normal
		);
		col = mix(col, outline_color, edge);
	}

	// Финальный клэмп и гамма-коррекция (опционально)
	ALBEDO = pow(clamp(col, 0.0, 1.0), vec3(0.95)); // лёгкая гамма для "плёночности"
}