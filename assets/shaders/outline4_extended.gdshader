shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
uniform sampler2D SCREEN_TEXTURE : source_color, hint_screen_texture, repeat_disable, filter_nearest;

uniform float zNear = 0.05;
uniform float zFar = 100;

uniform bool enable_outline = false;
uniform vec3 outline_color : source_color = vec3(0.0,0.0,0.0);
uniform float outline_thickness = 10.0;

uniform bool enable_color_limit = true;
uniform int color_levels : hint_range(2, 32) = 16;

uniform bool enable_color_palette = true;

// исходные
uniform vec4 color1  : source_color = vec4(1.0,0.925,0.839,1.0);
uniform vec4 color2  : source_color = vec4(1.0,0.831,0.639,1.0);
uniform vec4 color3  : source_color = vec4(1.0,0.667,0.369,1.0);
uniform vec4 color4  : source_color = vec4(0.816,0.506,0.349,1.0);
uniform vec4 color5  : source_color = vec4(0.553,0.412,0.478,1.0);
uniform vec4 color6  : source_color = vec4(0.329,0.306,0.408,1.0);
uniform vec4 color7  : source_color = vec4(0.125,0.236,0.337,1.0);
uniform vec4 color8  : source_color = vec4(0.05,0.169,0.271,1.0);

// добавленные (интерполяция)
uniform vec4 color9  : source_color = vec4(0.9,0.88,0.8,1.0);
uniform vec4 color10 : source_color = vec4(1.0,0.78,0.55,1.0);
uniform vec4 color11 : source_color = vec4(0.9,0.6,0.4,1.0);
uniform vec4 color12 : source_color = vec4(0.7,0.45,0.38,1.0);
uniform vec4 color13 : source_color = vec4(0.45,0.36,0.44,1.0);
uniform vec4 color14 : source_color = vec4(0.28,0.28,0.36,1.0);
uniform vec4 color15 : source_color = vec4(0.18,0.22,0.32,1.0);
uniform vec4 color16 : source_color = vec4(0.08,0.16,0.26,1.0);

uniform bool enable_dithering = true;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.3;

const mat3 Gx = mat3(
	vec3(-1,-2,-1),
	vec3(0,0,0),
	vec3(1,2,1)
);
const mat3 Gy = mat3(
	vec3(-1,0,1),
	vec3(-2,0,2),
	vec3(-1,0,1)
);

float depth(sampler2D depth_texture, vec2 screen_uv, mat4 inv_proj_mat, in vec3 vertex)
{
	float depth_raw = texture(depth_texture, screen_uv)[0];
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth_raw);
	vec4 view_space = inv_proj_mat * vec4(ndc,1.0);
	view_space.z /= view_space.w;
	float linear_depth = view_space.z;
	return (zFar-zNear)/(zNear + linear_depth * (zNear-zFar));
}

float sobel_depth(in vec2 uv, in vec2 offset, in vec3 vertex, mat4 inv_proj_mat)
{
	float xSob = 0.0;
	float ySob = 0.0;

	for (int r = 0; r < 3; r++)
	for (int c = 0; c < 3; c++)
	{
		float d = depth(DEPTH_TEXTURE, uv + offset * vec2(float(c)-1.0,float(r)-1.0), inv_proj_mat, vertex);
		xSob += Gx[r][c] * d;
		ySob += Gy[r][c] * d;
	}

	return sqrt(xSob*xSob + ySob*ySob);
}

float luminance(vec3 c)
{
	return dot(vec3(0.2125,0.7154,0.0721), c);
}

float sobel_normal(in vec2 uv, in vec2 offset)
{
	float xSob = 0.0;
	float ySob = 0.0;

	for (int r = 0; r < 3; r++)
	for (int c = 0; c < 3; c++)
	{
		float l = luminance(texture(NORMAL_TEXTURE, uv + offset * vec2(float(c)-1.0,float(r)-1.0)).rgb);
		xSob += Gx[r][c] * l;
		ySob += Gy[r][c] * l;
	}

	return sqrt(xSob*xSob + ySob*ySob);
}

float posterize(float v, int levels)
{
	return round(v * float(levels)) / float(levels);
}

float dither(vec2 pos, float b)
{
	int x = int(mod(pos.x, 4.0));
	int y = int(mod(pos.y, 4.0));
	int i = x + y * 4;

	float d[16] = float[](
		0.0,0.5,0.125,0.625,
		0.75,0.25,0.875,0.375,
		0.1875,0.6875,0.0625,0.5625,
		0.9375,0.4375,1.0,0.8125
	);

	return b < d[i] ? 0.0 : 1.0;
}

void vertex() {
	POSITION = vec4(VERTEX.xy,1.0,1.0);
}

void fragment() {

	vec3 palette[16];
	palette[0]=color1.rgb;
	palette[1]=color9.rgb;
	palette[2]=color2.rgb;
	palette[3]=color10.rgb;
	palette[4]=color3.rgb;
	palette[5]=color11.rgb;
	palette[6]=color4.rgb;
	palette[7]=color12.rgb;
	palette[8]=color5.rgb;
	palette[9]=color13.rgb;
	palette[10]=color6.rgb;
	palette[11]=color14.rgb;
	palette[12]=color7.rgb;
	palette[13]=color15.rgb;
	palette[14]=color8.rgb;
	palette[15]=color16.rgb;

	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	if(enable_color_limit)
	{
		col = vec3(
			posterize(col.r,color_levels),
			posterize(col.g,color_levels),
			posterize(col.b,color_levels)
		);
	}

	if(enable_color_palette)
	{
		vec3 best = palette[0];
		float best_d = dot(col - best, col - best);

		for(int i=1;i<16;i++)
		{
			float d = dot(col - palette[i], col - palette[i]);
			if(d < best_d)
			{
				best_d = d;
				best = palette[i];
			}
		}
		col = best;
	}

	if(enable_dithering)
	{
		float b = dot(col, vec3(0.3,0.59,0.11));
		col *= (1.0 + dither_strength * (dither(FRAGCOORD.xy,b)-0.5));
	}

	if(enable_outline)
	{
		vec2 off = outline_thickness / VIEWPORT_SIZE;
		float e = smoothstep(0.0,1.0,
			10.0 * sobel_depth(SCREEN_UV, off, VERTEX, INV_PROJECTION_MATRIX)
			+ sobel_normal(SCREEN_UV, off)
		);
		col = mix(col, outline_color, e);
	}

	ALBEDO = col;
}

void light() {}