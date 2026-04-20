extends Node2D

@onready var cam: Camera2D = $Camera2D

var dragging := false
var last_mouse_pos := Vector2.ZERO

var target_pos := Vector2.ZERO
var target_zoom := Vector2.ONE

var move_smooth := 48.0
var zoom_smooth := 48.0

var zoom_step := 0.4
var min_zoom := 0.25
var max_zoom := 1.0

@onready var sample = $Sample
@onready var sample_line := $Sample/Line/Regular
@onready var sample_line_hover := $Sample/Line/Hover
@onready var sample_card := $Sample/Card



func spawn_card(pos) -> BoardCard:
	var card : BoardCard = sample_card.duplicate()
	add_child(card)
	card.position = pos
	card.rotation = randf_range(-0.3, 0.3)
	#card.data = "KEK"
	return card

func make_rope(from: Vector2, to: Vector2, desc: String) -> void:
	var rope = sample_line.duplicate()
	rope.points = [from, to]
	var rope_hover = sample_line_hover.duplicate()
	rope_hover.points = [from, to]
	var area = BoardLine.new()
	area.description = desc
	add_child(area)
	area.add_child(rope)
	area.add_child(rope_hover)
	var thickness := 50.0
	var dir = (to - from).normalized()
	var normal = Vector2(-dir.y, dir.x) * thickness * 0.5
	var poly = PackedVector2Array([
		from + normal,
		from - normal,
		to - normal,
		to + normal
	])

	var shape = CollisionPolygon2D.new()
	shape.polygon = poly
	area.add_child(shape)

var hovered : BoardInspectable = null


@onready var in_a := $"../../../AspectRatioContainer/Control/Paper1Animator"
@onready var out_a := $"../../../AspectRatioContainer/Control/Paper2Animator"

@onready var paper_1_text: RichTextLabel = $"../../../AspectRatioContainer/Control/Paper1/Paper1Text"
@onready var paper_2_text: RichTextLabel = $"../../../AspectRatioContainer/Control/Paper2/Paper2Text"



func _ready():
	log_zoom_target = -2.0
	log_zoom_current = -3.5
	sample.hide()
	sample.process_mode = Node.PROCESS_MODE_DISABLED
	target_pos = cam.position
	target_zoom = cam.zoom
	RUMOR.hearing_unlocked.connect(on_hearing)
	RUMOR.connection_unlocked.connect(on_connection)
	RUMOR.description_unlocked.connect(on_description)
	RUMOR.image_discovered.connect(on_image_discovered)

var cards = {
	
}

func discover_card(k) -> BoardCard:
	var raw_data = RUMOR.hearings_data[k]
	var card = spawn_card(raw_data.position)
	card.data = raw_data
	card.init()
	cards[k] = card
	return card



func on_hearing(k):
	if cinematic_active or GLOBAL.ui_state != GLOBAL.UI_STATE.BOARD:
		pending_events.append({ "type": EventType.HEARING, "key": k })
	else:
		_apply_hearing(k)

func on_image_discovered(k):
	if cinematic_active or GLOBAL.ui_state != GLOBAL.UI_STATE.BOARD:
		pending_events.append({ "type": EventType.IMAGE, "key": k })
	else:
		_apply_image(k)

func on_description(k, i):
	if cinematic_active or GLOBAL.ui_state != GLOBAL.UI_STATE.BOARD:
		pending_events.append({ "type": EventType.DESCRIPTION, "key": k, "index": i })
	else:
		_apply_description(k, i)

func on_connection(f, t, d):
	if cinematic_active or GLOBAL.ui_state != GLOBAL.UI_STATE.BOARD:
		pending_events.append({ "type": EventType.CONNECTION, "from": f, "to": t, "desc": d })
	else:
		_apply_connection(f, t, d)

func get_text(c):
	return c.inspect()

var hover_null_timer: float = 0.0
var hover_null_delay: float = 0.15

func _process(dt: float) -> void:
	RUMOR.add_knowledge("located_signal")
	RUMOR.add_knowledge("found_signal")
	RUMOR.add_knowledge("visited_planet_x")
	var is_board = GLOBAL.ui_state == GLOBAL.UI_STATE.BOARD
	if is_board and !was_board: _on_enter_board()
	was_board = is_board
	if !is_board: return
	_on_enter_board()
	if cinematic_active:
		_tick_cinematic(dt)
	else:
		handle_cam(dt)
	_handle_hover(dt)
	request(hovered)

var current = null
var current_playing = false
var queued = null

func request(n):
	if n != current || n == null:
		queued = n
	if n == null && current && !current_playing:
		paper_2_text.text = paper_1_text.text
		in_a.play("RESET")
		$"../../../AspectRatioContainer/Control/Paper2".z_index = 2
		out_a.play("out")
		current = null
		return
	if current == null && n && !current_playing:
		in_a.play("in")
		current_playing = true
		current = n
		paper_1_text.text = get_text(current)
		queued = null
	if current_playing && n != current:
		queued = n
	if !current_playing && queued && queued:
		if current:
			paper_2_text.text = paper_1_text.text
			in_a.play("RESET")
			$"../../../AspectRatioContainer/Control/Paper2".z_index = 2
			out_a.play("out")
			current_playing = true
			current = queued
			paper_1_text.text = get_text(current)
			queued = null
			in_a.play("in")
		else:
			in_a.play("in")
			current_playing = true
			current = n
			paper_1_text.text = get_text(current)
			queued = null

func _on_out_finished(_t):
	pass

func _on_in_finished(t):
	if t != "in": return
	current_playing = false

func fake_reset():
	log_zoom_current = -3.5
	log_zoom_target = -2.0
	cam.zoom = Vector2.ONE * pow(2.0, log_zoom_current)
	#target_pos = Vector2.ZERO
	#cam.position = Vector2.ZERO

var log_zoom_target: float
var log_zoom_current: float

func handle_cam(dt):
	if Input.is_action_just_pressed("reset_view"):
		target_pos = Vector2.ZERO
		log_zoom_target = 0.0
	GLOBAL.dbg("AVB", log_zoom_current)
	var t = 1.0 - exp(-move_smooth * dt)
	log_zoom_current = lerp(log_zoom_current, log_zoom_target, t)
	var actual_zoom = pow(2.0, log_zoom_current)
	cam.zoom = Vector2(actual_zoom, actual_zoom)
	cam.position = cam.position.lerp(target_pos, t)

func _unhandled_input(event: InputEvent) -> void:
	if cinematic_active: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = get_viewport().get_mouse_position()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			change_zoom(zoom_step, get_viewport().get_mouse_position())
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			change_zoom(-zoom_step, get_viewport().get_mouse_position())
	elif event is InputEventMouseMotion and dragging:
		var current_pos = get_viewport().get_mouse_position()
		var delta = current_pos - last_mouse_pos
		target_pos -= delta / cam.zoom
		last_mouse_pos = current_pos

func change_zoom(amount: float, mouse_screen_pos: Vector2) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_offset = mouse_screen_pos - viewport_size * 0.5

	var old_zoom = Vector2.ONE * pow(2.0, log_zoom_target)

	log_zoom_target = clamp(
		log_zoom_target + amount,
		log(min_zoom) / log(2.0),
		log(max_zoom) / log(2.0)
	)
	var new_zoom = Vector2.ONE * pow(2.0, log_zoom_target)

	var world_before = target_pos + mouse_offset / old_zoom
	var world_after  = target_pos + mouse_offset / new_zoom
	target_pos += world_before - world_after

enum EventType { HEARING, IMAGE, DESCRIPTION, CONNECTION }

var pending_events: Array = []  # события пока не в BOARD
var cinematic_queue: Array = []  # текущая очередь для воспроизведения
var cinematic_active := false
var was_board := false

func _apply_hearing(k) -> BoardCard:
	if cards.get(k): return cards[k]
	return discover_card(k)

func _apply_image(k):
	var c: BoardCard = cards.get(k)
	if c: c.show_image()
	else: discover_card(k).show_image()

func _apply_description(k, i):
	var c: BoardCard = cards.get(k)
	if c: c.unlock(i)
	else: discover_card(k).unlock(i)

func _apply_connection(f, t, d):
	var pos = []
	for i in [f, t]:
		var c = cards.get(i)
		if c: pos.append(c.position); continue
		var raw = RUMOR.hearings_data[i]
		var card = spawn_card(raw.position)
		card.data = raw; card.init()
		pos.append(raw.position)
		cards[i] = card
	make_rope(pos[0], pos[1], d)

func _on_enter_board():
	if pending_events.is_empty(): return
	cinematic_queue = _build_cinematic_sequence(pending_events.duplicate())
	pending_events.clear()
	_start_cinematic()

func _build_cinematic_sequence(events: Array) -> Array:
	var sequence = []
	
	# Сначала — все новые карты (HEARING), которых ещё нет
	var new_cards = []
	for e in events:
		if e.type == EventType.HEARING and !cards.get(e.key):
			new_cards.append(e.key)
	
	# Группируем descriptions по ключу
	var descs_by_key = {}
	for e in events:
		if e.type == EventType.DESCRIPTION:
			if !descs_by_key.has(e.key): descs_by_key[e.key] = []
			descs_by_key[e.key].append(e.index)
	
	var images = []
	for e in events:
		if e.type == EventType.IMAGE: images.append(e.key)
	
	var connections = []
	for e in events:
		if e.type == EventType.CONNECTION: connections.append(e)
	
	# Собираем узлы к посещению — те у которых есть что показать
	var visited_keys = {}
	
	# Новые карточки
	for k in new_cards:
		visited_keys[k] = true
		var step = { "action": "visit_card", "key": k, "apply": [] }
		step.apply.append({ "type": EventType.HEARING, "key": k })
		if descs_by_key.has(k):
			for i in descs_by_key[k]:
				step.apply.append({ "type": EventType.DESCRIPTION, "key": k, "index": i })
			descs_by_key.erase(k)
		if k in images:
			step.apply.append({ "type": EventType.IMAGE, "key": k })
			images.erase(k)
		sequence.append(step)
	
	# Карты с новыми описаниями (уже существующие)
	for k in descs_by_key:
		var step = { "action": "visit_card", "key": k, "apply": [] }
		for i in descs_by_key[k]:
			step.apply.append({ "type": EventType.DESCRIPTION, "key": k, "index": i })
		if k in images:
			step.apply.append({ "type": EventType.IMAGE, "key": k })
			images.erase(k)
		sequence.append(step)
	
	# Оставшиеся images
	for k in images:
		var step = { "action": "visit_card", "key": k, "apply": [] }
		step.apply.append({ "type": EventType.IMAGE, "key": k })
		sequence.append(step)
	
	# Связи в конце
	for e in connections:
		sequence.append({ "action": "visit_connection", "event": e })
	
	# Финал — отдалить и вернуть управление
	sequence.append({ "action": "finish" })
	return sequence

# --- Кинематограф ---
var cinematic_step := 0
var cinematic_timer := 0.0
const FLY_DURATION    := 1.0   # секунд на перелёт
const LINGER_DURATION := 1.0   # секунд стоять у объекта

func _start_cinematic():
	cinematic_active = true
	cinematic_step = 0
	cinematic_timer = 0.0
	fake_reset()  # влетаем издалека
	_run_step()

func _run_step():
	if cinematic_step >= cinematic_queue.size():
		_end_cinematic()
		return
	
	var step = cinematic_queue[cinematic_step]
	
	match step.action:
		"visit_card":
			var k = step.key
			# Применяем создание карты немедленно, остальное — после прилёта
			if !cards.get(k):
				_apply_hearing(k)
			var card: BoardCard = cards[k]
			_fly_to(card.position, -1.0)  # -1.0 = log2(0.5), зум ×0.5
			cinematic_timer = FLY_DURATION
		
		"visit_connection":
			var e = step.event
			# Применяем связь сразу (нужны позиции обеих карт)
			_apply_connection(e.from, e.to, e.desc)
			var mid = _connection_midpoint(e.from, e.to)
			_fly_to(mid, -1.5)
			cinematic_timer = FLY_DURATION
		
		"finish":
			_fly_to(Vector2.ZERO, -2.0)
			cinematic_timer = 0.0 # FLY_DURATION + 0.1

func _apply_step_effects(step: Dictionary):
	if !step.has("apply"): return
	for a in step.apply:
		match a.type:
			EventType.DESCRIPTION: _apply_description(a.key, a.index)
			EventType.IMAGE:       _apply_image(a.key)

func _connection_midpoint(f, t) -> Vector2:
	var pf = cards[f].position if cards.has(f) else RUMOR.hearings_data[f].position
	var pt = cards[t].position if cards.has(t) else RUMOR.hearings_data[t].position
	return (pf + pt) * 0.5

func _fly_to(world_pos: Vector2, zoom_log: float):
	target_pos = world_pos
	log_zoom_target = zoom_log

# Обновление кинематографа — вызывается из _process
func _tick_cinematic(dt: float):
	if !cinematic_active: return
	handle_cam(dt)  # камера всё равно интерполируется
	
	cinematic_timer -= dt
	if cinematic_timer > 0.0: return
	
	var step = cinematic_queue[cinematic_step]
	if step.action == "finish":
		_end_cinematic()   # ← прилетели — сразу отдаём управление
		return
	# Прилетели — применяем эффекты и ждём LINGER
	if cinematic_timer > -LINGER_DURATION:
		_apply_step_effects(step)
		return
	
	# Отстояли — следующий шаг
	cinematic_step += 1
	cinematic_timer = 0.0
	_run_step()

func _end_cinematic():
	cinematic_active = false
	log_zoom_target = -2.0

func _handle_hover(dt: float):
	if cinematic_active:
		if hovered: hovered.unfocus(); hovered = null
		return
	
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false

	var result = space_state.intersect_point(params)
	if result:
		hover_null_timer = 0.0
		var pn = null; var pnv = 0
		for r in result:
			var a: Area2D = r.collider
			if pn == null || a.priority > pnv: pn = a; pnv = a.priority
		if hovered != pn:
			if hovered: hovered.unfocus()
			hovered = pn; hovered.focus()
	else:
		hover_null_timer += dt
		if hover_null_timer >= hover_null_delay:
			if hovered: hovered.unfocus(); hovered = null
