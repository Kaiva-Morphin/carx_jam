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

func on_hearing(k):
	var c = cards.get(k)
	if c:
		return
	discover_card(k)

func discover_card(k) -> BoardCard:
	var raw_data = RUMOR.hearings_data[k]
	var card = spawn_card(raw_data.position)
	card.data = raw_data
	card.init()
	cards[k] = card
	return card

func on_image_discovered(k):
	var c : BoardCard = cards.get(k)
	if c:
		c.show_image()
	else:
		var card = discover_card(k)
		card.show_image()

func on_description(k, i):
	var c : BoardCard = cards.get(k)
	if c:
		c.unlocked.append(i)
	else:
		var card = discover_card(k)
		card.unlocked.append(i)

func on_connection(f, t, d):
	var pos = []
	for i in [f, t]:
		var c = cards.get(i)
		if c:
			pos.append(c.position)
			continue
		var raw_data = RUMOR.hearings_data[i]
		var card = spawn_card(raw_data.position)
		card.data = raw_data
		card.init()
		pos.append(raw_data.position)
		cards[i] = card
	make_rope(pos[0], pos[1], d)

func get_text(c):
	return c.inspect()

var hover_null_timer: float = 0.0
var hover_null_delay: float = 0.15  # секунд, подбери под себя

func _process(dt: float) -> void:
	RUMOR.add_knowledge("visited_planet_x")
	if GLOBAL.ui_state != GLOBAL.UI_STATE.BOARD: return
	handle_cam(dt)

	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false

	var result = space_state.intersect_point(params)
	if result:
		hover_null_timer = 0.0  # сбрасываем таймер — что-то под курсором есть

		var pn = null
		var pnv = 0
		for r in result:
			var a : Area2D = r.collider
			if pn == null || a.priority > pnv:
				pn = a
				pnv = a.priority

		if hovered != pn:
			if hovered:
				hovered.unfocus()
			hovered = pn
			hovered.focus()
	else:
		hover_null_timer += dt
		if hover_null_timer >= hover_null_delay:
			if hovered:
				hovered.unfocus()
				hovered = null

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
