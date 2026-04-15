shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void vertex() {
	//POSITION = vec4(VERTEX, 1.0);
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float get_linear_depth(sampler2D sampler, vec2 coords, mat4 ipm){
	float depth = texture(sampler, coords).r;
	vec3 ndc = vec3(coords, depth) * 2.0 - 1.0;
	vec4 view = ipm * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	return linear_depth;
}

vec3 normal_from_depth(vec2 uv, mat4 inv_proj_mat){
	float depth = texture(DEPTH_TEXTURE, uv).r;
	
	//Normal recontruction from Depth:
	float x = uv.x * 2.0 - 1.0;
	float y = (1.0 - uv.y) * 2.0 - 1.0;
	
	vec4 position_s = vec4(x, y, depth, 1.0);
	vec4 position_v = inv_proj_mat * position_s;
	
	vec3 P = position_v.xyz / position_v.w;
	
	//inverting P's y axis and calculating the cross product of dFdy first and dFdx later fixes the y axis
	P.y = -P.y;
	return normalize(cross(dFdy(P), dFdx(P)));
}

float getGrayScale(vec3 color){
	float gray = (color.r + color.g + color.b)/3.0;
	return gray;
}

void fragment() {
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 1));
	float px = 0.5/screen_size.x;
	float py = 0.5/screen_size.y;
	//ALBEDO = vec3(normal);
	float linear_depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
	float ld1 = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
	float ld2 = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV + vec2(px,0), INV_PROJECTION_MATRIX);
	float ld3 = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV + vec2(0,py), INV_PROJECTION_MATRIX);
	
	
	vec3 n1 = normal_from_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
	vec3 n2 = normal_from_depth(SCREEN_UV + vec2(px,0), INV_PROJECTION_MATRIX);
	vec3 n3 = normal_from_depth(SCREEN_UV + vec2(0,py), INV_PROJECTION_MATRIX);
	
	//vec3 albedo = texture(ALBEDO_TEXTURE, SCREEN_UV).rgb;
	
	float d1 = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	float d2 = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, py)).x;
	float d3 = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, 0.0)).x;
	vec3 s1 = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 c = s1;
	//c.rgb = vec3(abs(d - du));
	//c = vec3(d);
	float dt = 0.001;
	if (
		abs(d1 - d2) > dt ||
		abs(d1 - d3) > dt
	) {
		//c = vec3(0.0);
	}
	float dt2 = 0.001;
	if (
		abs(ld1 - ld2) > dt2 ||
		abs(ld1 - ld3) > dt2
	) {
		c = vec3(0.0);
	}
	// 100000.0
	//c = vec3(linear_depth);
	//c = vec3(0.0);
	
	//c = texture(NORMAL_TEXTURE, SCREEN_UV).xyz * 2.0 - 1.0;
	//c = normal;
	//float dd = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, -py)).x;
	//float dr = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(px, 0.0)).x;
	//float dl = texture(DEPTH_TEXTURE, SCREEN_UV+vec2(-px, 0.0)).x;
	float n1g = getGrayScale(n1);
	float n2g = getGrayScale(n2);
	float n3g = getGrayScale(n3);
	float normal_factor = 0.5;
	if (abs(n1g - n2g) > normal_factor || abs(n1g - n3g) > normal_factor ) {
		//c = vec3(0.0);
	}
	//float
	
	vec3 s2 = texture(SCREEN_TEXTURE, SCREEN_UV + px).rgb;
	vec3 s3 = texture(SCREEN_TEXTURE, SCREEN_UV + py).rgb;
	
	float color_factor = 0.01;
	if (
		s1.g - s2.g > color_factor
		//s1.r - s2.r > color_fact
	) {
		//c = vec3(0.0);
	}
	//c = vec3(s1.r - s2.r);
	//c = vec3(abs(s1.g-s2.g));
	ALBEDO = c;
	ALPHA = 1.0;
}
