shader_type canvas_item;

uniform sampler2D fill_texture_overlay;
uniform sampler2D bg_texture;
uniform float fill_ratio: hint_range(0., 1.) = 1.;
uniform float start_angle: hint_range(0., 360.) = 0.;
uniform float max_angle: hint_range(0., 360.) = 360.;
uniform bool invert_fill = false;
uniform bool reflect_x = false;
uniform bool reflect_y = false;
uniform vec2 offset = vec2(0., 0.);

// Ширина сглаживания в радианах
uniform float smooth_width:hint_range(0.0, 1.0) = 0.05;

mat2 tex_rotate(float _angle){
	return mat2(vec2(cos(_angle), -sin(_angle)), vec2(sin(_angle), cos(_angle)));
}

void fragment() {
	// 1. Подготовка UV
	vec2 uv = ((UV * 2. - 1.) + offset) * tex_rotate(-radians(start_angle));
	
	if (reflect_x) {
		uv *= mat2(vec2(-1., 0.), vec2(0., 1.));
	}
	if (reflect_y) {
		uv *= mat2(vec2(1., 0.), vec2(0., -1.));
	}
		
	// 2. Вычисление текущего угла [0, 2*PI]
	float current_angle = atan(uv.y, uv.x);
	if (current_angle < 0.0) {
		current_angle += 2.0 * PI;
	}
	
	// 3. Вычисление целевого угла заполнения
	float fill_angle_rad = radians(fill_ratio * max_angle);
	
	// 4. Расчет маски с учетом сглаживания обеих границ
	
	float mask_factor;
	
	if (!invert_fill) {
		// Нормальный режим: заполнение от 0 до fill_angle_rad
		
		// Левая граница (начало, около 0/2PI):
		// Нам нужно, чтобы значение росло от 0 до 1 при переходе через 0.
		// Используем тот факт, что angles близки к 0 или 2PI.
		// smoothstep(0, smooth_width, current_angle) даст 1 справа от 0.
		// Но нам нужно учесть переход через 2PI -> 0.
		
		// Простой способ для сектора, не пересекающего 0 (так как мы повернули UV на start_angle):
		// Начало сектора всегда примерно на 0 (или 2PI).
		
		// Фактор начала: плавное появление от 0
		float start_edge = smoothstep(0.0, smooth_width, current_angle);
		
		// Если угол очень близок к 2PI, он тоже должен считаться "началом" (для замыкания круга),
		// но так как мы рисуем сектор от 0 до X, то область near 2PI обычно пустая (фон).
		// Однако, если fill_ratio почти 1, нам нужно сгладить стык.
		
		// Более надежный метод для "круглого" начала и конца:
		// Расстояние от текущего угла до ближайшей границы сектора.
		
		// Граница 1: 0 (или 2PI)
		// Граница 2: fill_angle_rad
		
		// Создаем маску для внутренней части сектора
		// Часть 1: Угол больше начала (с учетом сглаживания)
		float after_start = smoothstep(0.0, smooth_width, current_angle);
		
		// Часть 2: Угол меньше конца (с учетом сглаживания)
		float before_end = 1.0 - smoothstep(fill_angle_rad - smooth_width, fill_angle_rad + smooth_width, current_angle);
		
		// Комбинируем: пиксель виден, если он ПОСЛЕ начала И ДО конца
		mask_factor = after_start * before_end;
		
		// Коррекция для случая, когда fill_ratio близок к 1 (полный круг)
		// Если fill_angle_rad близок к 2PI, то before_end станет 0 near 2PI, что разрежет круг.
		// Если fill_ratio == 1, мы хотим полный круг.
		if (fill_ratio >= 1.0) {
			mask_factor = 1.0;
		}
		
	} else {
		// Инвертированный режим: заполнено все, КРОМЕ сектора от 0 до fill_angle_rad
		
		// Маска "дырки"
		float hole_start = smoothstep(0.0, smooth_width, current_angle);
		float hole_end = 1.0 - smoothstep(fill_angle_rad - smooth_width, fill_angle_rad + smooth_width, current_angle);
		float hole_mask = hole_start * hole_end;
		
		// Инвертируем маску дырки, чтобы получить заполнение
		mask_factor = 1.0 - hole_mask;
		
		if (fill_ratio >= 1.0) {
			// Если инвертировано и заполнение 100%, то "дырка" занимает весь круг, значит цвет фона везде?
			// Или наоборот? Обычно invert_fill меняет местами TEXTURE и BG.
			// В оригинальном коде: if invert -> atan > fill. То есть заполнено "остальное".
			// Если fill_ratio = 1, дырка во весь круг, значит mask_factor = 0 (виден BG).
			mask_factor = 0.0; 
		}
	}
	
	// 5. Смешивание цветов
	vec4 fill_color = texture(TEXTURE, UV) * texture(fill_texture_overlay, UV);
	vec4 bg_color = texture(bg_texture, UV);
	
	COLOR = mix(bg_color, fill_color, mask_factor);
	if (fill_ratio == 0.0) {
		COLOR = bg_color;
	}
	if (fill_ratio == 1.0) {
		COLOR = fill_color;
	}
}