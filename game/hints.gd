extends MarginContainer


var hints = {}


@onready var sample = $VBoxContainer/HintSample

func rm_all():
	rm_center_hint()
	for h in hints:
		hints[h].node.queue_free()
		hints.erase(h)

func _ready():
	sample.process_mode = Node.PROCESS_MODE_DISABLED
	sample.hide()
	GLOBAL.hints = self
	var e = InputMap.action_get_events("zoom_in")

var center_key = "UNK"
var center_label = "UNK"
func center_hint(keymap, label):
	$HintCenter.show()
	if center_key == keymap:
		if center_label == label:
			return
	center_key = keymap
	$HintCenter/Label.text = label
	center_label = label
	$HintCenter/KeyTexture.texture = get_action_button_glyph(keymap)


func rm_center_hint():
	$HintCenter.hide()

func hint(keymap, label):
	var h = hints.get(keymap)
	if h:
		if h.label == label:
			return
	var s = sample.duplicate()
	s.show()
	s.process_mode = Node.PROCESS_MODE_INHERIT
	s.key_texture(get_action_button_glyph(keymap))
	s.label(label)
	$VBoxContainer.add_child(s)
	hints[keymap] = {"node": s, "keymap": keymap, "label": label}

var is_gamepad = false

func update_hints():
	for hk in hints:
		hints[hk].node.key_texture(get_action_button_glyph(hints[hk].keymap))
	$HintCenter/KeyTexture.texture = get_action_button_glyph(center_key)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey || event is InputEventMouseButton || event is InputEventMouseMotion:
		if event is InputEventMouseMotion:
			if abs(event.relative.length()) < 0.1: return
		if is_gamepad:
			is_gamepad = false
			update_hints()
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) < 0.1: return
		if !is_gamepad:
			is_gamepad = true
			update_hints()
#
func rm_hint(keymap):
	var h = hints.get(keymap)
	if !h: return
	h.node.queue_free()
	hints.erase(keymap)


func get_action_button_glyph(action_name: String) -> Texture2D:
	var events = InputMap.action_get_events(action_name)
	if events.is_empty():
		return null
	var non_gamepad = "FALLBACK"
	for event in events:
		if event is InputEventKey:
			var keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			non_gamepad = get_keyboard_texture(OS.get_keycode_string(keycode))
		elif event is InputEventMouseButton:
			non_gamepad = get_mouse_texture(event.button_index)
		if is_gamepad:
			if event is InputEventJoypadButton:
				return get_gamepad_texture(event.button_index)
			elif event is InputEventJoypadMotion:
				return get_joypad_texture(event.axis)
	if is_gamepad:
		printerr("non_gamepad")
	return non_gamepad



func get_keyboard_texture(key: String) -> Texture2D:
	var textures = {
		# Буквы
		"A": KB_A, "B": KB_B, "C": KB_C, "D": KB_D, "E": KB_E, "F": KB_F,
		"G": KB_G, "H": KB_H, "I": KB_I, "J": KB_J, "K": KB_K, "L": KB_L,
		"M": KB_M, "N": KB_N, "O": KB_O, "P": KB_P, "Q": KB_Q, "R": KB_R,
		"S": KB_S, "T": KB_T, "U": KB_U, "V": KB_V, "W": KB_W, "X": KB_X,
		"Y": KB_Y, "Z": KB_Z,
		# Цифры
		"0": KB_0, "1": KB_1, "2": KB_2, "3": KB_3, "4": KB_4,
		"5": KB_5, "6": KB_6, "7": KB_7, "8": KB_8, "9": KB_9,
		# Стрелки
		"Up": KB_ARROW_UP, "Down": KB_ARROW_DOWN, "Left": KB_ARROW_LEFT, "Right": KB_ARROW_RIGHT,
		"Arrow Up": KB_ARROW_UP, "Arrow Down": KB_ARROW_DOWN, "Arrow Left": KB_ARROW_LEFT, "Arrow Right": KB_ARROW_RIGHT,
		# Модификаторы
		"Shift": KB_SHIFT, "Ctrl": KB_CTRL, "Control": KB_CTRL,
		"Alt": KB_ALT, "Meta": KB_WIN, "Command": KB_COMMAND, "Win": KB_WIN, "Option": KB_OPTION,
		# Основные клавиши
		"Enter": KB_ENTER, "Return": KB_RETURN, "Space": KB_SPACE,
		"Tab": KB_TAB, "Escape": KB_ESCAPE, "Backspace": KB_BACKSPACE,
		"Delete": KB_DELETE, "Insert": KB_INSERT, "Home": KB_HOME, "End": KB_END,
		"Page Up": KB_PAGE_UP, "Page Down": KB_PAGE_DOWN,
		"Caps Lock": KB_CAPSLOCK, "Num Lock": KB_NUMLOCK, "Print Screen": KB_PRINTSCREEN,
		"Pause": KB_FUNCTION, "Menu": KB_FUNCTION,
		# Функциональные
		"F1": KB_F1, "F2": KB_F2, "F3": KB_F3, "F4": KB_F4,
		"F5": KB_F5, "F6": KB_F6, "F7": KB_F7, "F8": KB_F8,
		"F9": KB_F9, "F10": KB_F10, "F11": KB_F11, "F12": KB_F12,
		# Символы
		",": KB_COMMA, ".": KB_PERIOD, "/": KB_SLASH_FORWARD, "\\": KB_SLASH_BACK,
		";": KB_SEMICOLON, "'": KB_APOSTROPHE, "\"": KB_QUOTE,
		"[": KB_BRACKET_OPEN, "]": KB_BRACKET_CLOSE,
		"<": KB_BRACKET_LESS, ">": KB_BRACKET_GREATER,
		"-": KB_MINUS, "=": KB_EQUALS, "+": KB_PLUS, "*": KB_ASTERISK,
		"`": KB_TILDE, "~": KB_TILDE, "^": KB_CARET,
		"!": KB_EXCLAMATION, "?": KB_QUESTION, ":": KB_COLON,
		# Специальные названия
		"Plus": KB_PLUS, "Minus": KB_MINUS, "Asterisk": KB_ASTERISK,
		"Slash": KB_SLASH_FORWARD, "Backslash": KB_SLASH_BACK,
		"Period": KB_PERIOD, "Comma": KB_COMMA, "Semicolon": KB_SEMICOLON,
		"Colon": KB_COLON, "Quote": KB_QUOTE, "Apostrophe": KB_APOSTROPHE,
		"Tilde": KB_TILDE, "Caret": KB_CARET, "Exclamation": KB_EXCLAMATION,
		"Question": KB_QUESTION, "Equals": KB_EQUALS,
		"Bracket Open": KB_BRACKET_OPEN, "Bracket Close": KB_BRACKET_CLOSE,
		"Bracket Less": KB_BRACKET_LESS, "Bracket Greater": KB_BRACKET_GREATER,
		# Нумпад
		"Kp Enter": KB_NUMPAD_ENTER, "Numpad Enter": KB_NUMPAD_ENTER,
		"Kp Plus": KB_NUMPAD_PLUS, "Numpad Plus": KB_NUMPAD_PLUS,
		"Kp 0": KB_0, "Kp 1": KB_1, "Kp 2": KB_2, "Kp 3": KB_3,
		"Kp 4": KB_4, "Kp 5": KB_5, "Kp 6": KB_6, "Kp 7": KB_7,
		"Kp 8": KB_8, "Kp 9": KB_9,
	}
	return textures.get(key, KB_GENERIC)

func get_joypad_texture(button_index: int) -> Texture2D:
	var textures = {
		4: PS_BTN_L2, 5: PS_BTN_R2,
	}
	return textures.get(button_index, PS_CONTROLLER_4)

func get_gamepad_texture(button_index: int) -> Texture2D:
	var textures = {
		# Face buttons
		0: PS_BTN_CROSS,    # A / Cross
		1: PS_BTN_CIRCLE,   # B / Circle
		2: PS_BTN_SQUARE,   # X / Square
		3: PS_BTN_TRIANGLE, # Y / Triangle
		# Shoulder
		4: PS_BTN_L1, 5: PS_BTN_R1,
		# Stick press
		6: PS_BTN_L3, 7: PS_BTN_R3,
		# System
		8: PS_BTN_OPTIONS, 9: PS_BTN_L1, 10: PS_BTN_R1,
		# D-Pad
		11: PS_DPAD_UP, 12: PS_DPAD_DOWN, 13: PS_DPAD_LEFT, 14: PS_DPAD_RIGHT,
		# Triggers
		15: PS_BTN_L2, 16: PS_BTN_R2,
		# Misc
		17: PS_STICK_L,
	}
	return textures.get(button_index, PS_CONTROLLER_4)

func get_mouse_texture(button_index: int) -> Texture2D:
	match button_index:
		MOUSE_BUTTON_LEFT:   return MOUSE_LEFT
		MOUSE_BUTTON_RIGHT:  return MOUSE_RIGHT
		MOUSE_BUTTON_MIDDLE: return MOUSE_SCROLL
		MOUSE_BUTTON_WHEEL_UP:   return MOUSE_SCROLL_UP
		MOUSE_BUTTON_WHEEL_DOWN: return MOUSE_SCROLL_DOWN
		_: return MOUSE_GENERIC


# === ПУТЬ К АССЕТАМ (настроить под ваш проект) ===
const ASSET_PATH_KB: String = "res://assets/keys/"
const ASSET_PATH_PS: String = "res://assets/keys/"
const ASSET_PATH_MOUSE: String = "res://assets/keys/"

# === ПРЕЗАГРУЗКА ТЕКСТУР: Клавиатура ===
const KB_GENERIC: Texture2D = preload(ASSET_PATH_KB + "keyboard.png")
const KB_0: Texture2D = preload(ASSET_PATH_KB + "keyboard_0.png")
const KB_1: Texture2D = preload(ASSET_PATH_KB + "keyboard_1.png")
const KB_2: Texture2D = preload(ASSET_PATH_KB + "keyboard_2.png")
const KB_3: Texture2D = preload(ASSET_PATH_KB + "keyboard_3.png")
const KB_4: Texture2D = preload(ASSET_PATH_KB + "keyboard_4.png")
const KB_5: Texture2D = preload(ASSET_PATH_KB + "keyboard_5.png")
const KB_6: Texture2D = preload(ASSET_PATH_KB + "keyboard_6.png")
const KB_7: Texture2D = preload(ASSET_PATH_KB + "keyboard_7.png")
const KB_8: Texture2D = preload(ASSET_PATH_KB + "keyboard_8.png")
const KB_9: Texture2D = preload(ASSET_PATH_KB + "keyboard_9.png")
const KB_A: Texture2D = preload(ASSET_PATH_KB + "keyboard_a.png")
const KB_B: Texture2D = preload(ASSET_PATH_KB + "keyboard_b.png")
const KB_C: Texture2D = preload(ASSET_PATH_KB + "keyboard_c.png")
const KB_D: Texture2D = preload(ASSET_PATH_KB + "keyboard_d.png")
const KB_E: Texture2D = preload(ASSET_PATH_KB + "keyboard_e.png")
const KB_F: Texture2D = preload(ASSET_PATH_KB + "keyboard_f.png")
const KB_G: Texture2D = preload(ASSET_PATH_KB + "keyboard_g.png")
const KB_H: Texture2D = preload(ASSET_PATH_KB + "keyboard_h.png")
const KB_I: Texture2D = preload(ASSET_PATH_KB + "keyboard_i.png")
const KB_J: Texture2D = preload(ASSET_PATH_KB + "keyboard_j.png")
const KB_K: Texture2D = preload(ASSET_PATH_KB + "keyboard_k.png")
const KB_L: Texture2D = preload(ASSET_PATH_KB + "keyboard_l.png")
const KB_M: Texture2D = preload(ASSET_PATH_KB + "keyboard_m.png")
const KB_N: Texture2D = preload(ASSET_PATH_KB + "keyboard_n.png")
const KB_O: Texture2D = preload(ASSET_PATH_KB + "keyboard_o.png")
const KB_P: Texture2D = preload(ASSET_PATH_KB + "keyboard_p.png")
const KB_Q: Texture2D = preload(ASSET_PATH_KB + "keyboard_q.png")
const KB_R: Texture2D = preload(ASSET_PATH_KB + "keyboard_r.png")
const KB_S: Texture2D = preload(ASSET_PATH_KB + "keyboard_s.png")
const KB_T: Texture2D = preload(ASSET_PATH_KB + "keyboard_t.png")
const KB_U: Texture2D = preload(ASSET_PATH_KB + "keyboard_u.png")
const KB_V: Texture2D = preload(ASSET_PATH_KB + "keyboard_v.png")
const KB_W: Texture2D = preload(ASSET_PATH_KB + "keyboard_w.png")
const KB_X: Texture2D = preload(ASSET_PATH_KB + "keyboard_x.png")
const KB_Y: Texture2D = preload(ASSET_PATH_KB + "keyboard_y.png")
const KB_Z: Texture2D = preload(ASSET_PATH_KB + "keyboard_z.png")

const KB_ALT: Texture2D = preload(ASSET_PATH_KB + "keyboard_alt.png")
const KB_ANY: Texture2D = preload(ASSET_PATH_KB + "keyboard_any.png")
const KB_APOSTROPHE: Texture2D = preload(ASSET_PATH_KB + "keyboard_apostrophe.png")
const KB_ARROW_DOWN: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrow_down.png")
const KB_ARROW_LEFT: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrow_left.png")
const KB_ARROW_RIGHT: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrow_right.png")
const KB_ARROW_UP: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrow_up.png")
const KB_ARROWS: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows.png")
const KB_ARROWS_ALL: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_all.png")
const KB_ARROWS_DOWN: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_down.png")
const KB_ARROWS_HORIZONTAL: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_horizontal.png")
const KB_ARROWS_LEFT: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_left.png")
const KB_ARROWS_NONE: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_none.png")
const KB_ARROWS_RIGHT: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_right.png")
const KB_ARROWS_UP: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_up.png")
const KB_ARROWS_VERTICAL: Texture2D = preload(ASSET_PATH_KB + "keyboard_arrows_vertical.png")
const KB_ASTERISK: Texture2D = preload(ASSET_PATH_KB + "keyboard_asterisk.png")
const KB_BACKSPACE: Texture2D = preload(ASSET_PATH_KB + "keyboard_backspace.png")
const KB_BACKSPACE_ICON: Texture2D = preload(ASSET_PATH_KB + "keyboard_backspace_icon.png")
const KB_BRACKET_CLOSE: Texture2D = preload(ASSET_PATH_KB + "keyboard_bracket_close.png")
const KB_BRACKET_GREATER: Texture2D = preload(ASSET_PATH_KB + "keyboard_bracket_greater.png")
const KB_BRACKET_LESS: Texture2D = preload(ASSET_PATH_KB + "keyboard_bracket_less.png")
const KB_BRACKET_OPEN: Texture2D = preload(ASSET_PATH_KB + "keyboard_bracket_open.png")
const KB_CAPSLOCK: Texture2D = preload(ASSET_PATH_KB + "keyboard_capslock.png")
const KB_CAPSLOCK_ICON: Texture2D = preload(ASSET_PATH_KB + "keyboard_capslock_icon.png")
const KB_CARET: Texture2D = preload(ASSET_PATH_KB + "keyboard_caret.png")
const KB_COLON: Texture2D = preload(ASSET_PATH_KB + "keyboard_colon.png")
const KB_COMMA: Texture2D = preload(ASSET_PATH_KB + "keyboard_comma.png")
const KB_COMMAND: Texture2D = preload(ASSET_PATH_KB + "keyboard_command.png")
const KB_CTRL: Texture2D = preload(ASSET_PATH_KB + "keyboard_ctrl.png")
const KB_DELETE: Texture2D = preload(ASSET_PATH_KB + "keyboard_delete.png")
const KB_END: Texture2D = preload(ASSET_PATH_KB + "keyboard_end.png")
const KB_ENTER: Texture2D = preload(ASSET_PATH_KB + "keyboard_enter.png")
const KB_EQUALS: Texture2D = preload(ASSET_PATH_KB + "keyboard_equals.png")
const KB_ESCAPE: Texture2D = preload(ASSET_PATH_KB + "keyboard_escape.png")
const KB_EXCLAMATION: Texture2D = preload(ASSET_PATH_KB + "keyboard_exclamation.png")
const KB_F1: Texture2D = preload(ASSET_PATH_KB + "keyboard_f1.png")
const KB_F2: Texture2D = preload(ASSET_PATH_KB + "keyboard_f2.png")
const KB_F3: Texture2D = preload(ASSET_PATH_KB + "keyboard_f3.png")
const KB_F4: Texture2D = preload(ASSET_PATH_KB + "keyboard_f4.png")
const KB_F5: Texture2D = preload(ASSET_PATH_KB + "keyboard_f5.png")
const KB_F6: Texture2D = preload(ASSET_PATH_KB + "keyboard_f6.png")
const KB_F7: Texture2D = preload(ASSET_PATH_KB + "keyboard_f7.png")
const KB_F8: Texture2D = preload(ASSET_PATH_KB + "keyboard_f8.png")
const KB_F9: Texture2D = preload(ASSET_PATH_KB + "keyboard_f9.png")
const KB_F10: Texture2D = preload(ASSET_PATH_KB + "keyboard_f10.png")
const KB_F11: Texture2D = preload(ASSET_PATH_KB + "keyboard_f11.png")
const KB_F12: Texture2D = preload(ASSET_PATH_KB + "keyboard_f12.png")
const KB_FUNCTION: Texture2D = preload(ASSET_PATH_KB + "keyboard_function.png")
const KB_HOME: Texture2D = preload(ASSET_PATH_KB + "keyboard_home.png")
const KB_INSERT: Texture2D = preload(ASSET_PATH_KB + "keyboard_insert.png")
const KB_MINUS: Texture2D = preload(ASSET_PATH_KB + "keyboard_minus.png")
const KB_NUMLOCK: Texture2D = preload(ASSET_PATH_KB + "keyboard_numlock.png")
const KB_NUMPAD_ENTER: Texture2D = preload(ASSET_PATH_KB + "keyboard_numpad_enter.png")
const KB_NUMPAD_PLUS: Texture2D = preload(ASSET_PATH_KB + "keyboard_numpad_plus.png")
const KB_OPTION: Texture2D = preload(ASSET_PATH_KB + "keyboard_option.png")
const KB_PAGE_DOWN: Texture2D = preload(ASSET_PATH_KB + "keyboard_page_down.png")
const KB_PAGE_UP: Texture2D = preload(ASSET_PATH_KB + "keyboard_page_up.png")
const KB_PERIOD: Texture2D = preload(ASSET_PATH_KB + "keyboard_period.png")
const KB_PLUS: Texture2D = preload(ASSET_PATH_KB + "keyboard_plus.png")
const KB_PRINTSCREEN: Texture2D = preload(ASSET_PATH_KB + "keyboard_printscreen.png")
const KB_QUESTION: Texture2D = preload(ASSET_PATH_KB + "keyboard_question.png")
const KB_QUOTE: Texture2D = preload(ASSET_PATH_KB + "keyboard_quote.png")
const KB_RETURN: Texture2D = preload(ASSET_PATH_KB + "keyboard_return.png")
const KB_SEMICOLON: Texture2D = preload(ASSET_PATH_KB + "keyboard_semicolon.png")
const KB_SHIFT: Texture2D = preload(ASSET_PATH_KB + "keyboard_shift.png")
const KB_SHIFT_ICON: Texture2D = preload(ASSET_PATH_KB + "keyboard_shift_icon.png")
const KB_SLASH_BACK: Texture2D = preload(ASSET_PATH_KB + "keyboard_slash_back.png")
const KB_SLASH_FORWARD: Texture2D = preload(ASSET_PATH_KB + "keyboard_slash_forward.png")
const KB_SPACE: Texture2D = preload(ASSET_PATH_KB + "keyboard_space.png")
const KB_SPACE_ICON: Texture2D = preload(ASSET_PATH_KB + "keyboard_space_icon.png")
const KB_TAB: Texture2D = preload(ASSET_PATH_KB + "keyboard_tab.png")
const KB_TAB_ICON: Texture2D = preload(ASSET_PATH_KB + "keyboard_tab_icon.png")
const KB_TILDE: Texture2D = preload(ASSET_PATH_KB + "keyboard_tilde.png")
const KB_WIN: Texture2D = preload(ASSET_PATH_KB + "keyboard_win.png")

# === ПРЕЗАГРУЗКА ТЕКСТУР: Мышь ===
const MOUSE_GENERIC: Texture2D = preload(ASSET_PATH_MOUSE + "mouse.png")
const MOUSE_LEFT: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_left.png")
const MOUSE_RIGHT: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_right.png")
const MOUSE_SCROLL: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_scroll.png")
const MOUSE_SCROLL_UP: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_scroll_up.png")
const MOUSE_SCROLL_DOWN: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_scroll_down.png")
const MOUSE_SCROLL_VERTICAL: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_scroll_vertical.png")
const MOUSE_MOVE: Texture2D = preload(ASSET_PATH_MOUSE + "mouse_move.png")

# === ПРЕЗАГРУЗКА ТЕКСТУР: PlayStation ===
const PS_CONTROLLER_1: Texture2D = preload(ASSET_PATH_PS + "controller_playstation1.png")
const PS_CONTROLLER_2: Texture2D = preload(ASSET_PATH_PS + "controller_playstation2.png")
const PS_CONTROLLER_3: Texture2D = preload(ASSET_PATH_PS + "controller_playstation3.png")
const PS_CONTROLLER_4: Texture2D = preload(ASSET_PATH_PS + "controller_playstation4.png")
const PS_CONTROLLER_5: Texture2D = preload(ASSET_PATH_PS + "controller_playstation5.png")

const PS_BTN_CROSS: Texture2D = preload(ASSET_PATH_PS + "playstation_button_cross.png")
const PS_BTN_CIRCLE: Texture2D = preload(ASSET_PATH_PS + "playstation_button_circle.png")
const PS_BTN_SQUARE: Texture2D = preload(ASSET_PATH_PS + "playstation_button_square.png")
const PS_BTN_TRIANGLE: Texture2D = preload(ASSET_PATH_PS + "playstation_button_triangle.png")
const PS_BTN_L1: Texture2D = preload(ASSET_PATH_PS + "playstation_trigger_l1.png")
const PS_BTN_R1: Texture2D = preload(ASSET_PATH_PS + "playstation_trigger_r1.png")
const PS_BTN_L2: Texture2D = preload(ASSET_PATH_PS + "playstation_trigger_l2.png")
const PS_BTN_R2: Texture2D = preload(ASSET_PATH_PS + "playstation_trigger_r2.png")
const PS_BTN_L3: Texture2D = preload(ASSET_PATH_PS + "playstation_button_l3.png")
const PS_BTN_R3: Texture2D = preload(ASSET_PATH_PS + "playstation_button_r3.png")
const PS_BTN_OPTIONS: Texture2D = preload(ASSET_PATH_PS + "playstation4_button_options.png")
const PS_BTN_SHARE: Texture2D = preload(ASSET_PATH_PS + "playstation4_button_share.png")
const PS_BTN_CREATE: Texture2D = preload(ASSET_PATH_PS + "playstation5_button_create.png")
const PS_BTN_MUTE: Texture2D = preload(ASSET_PATH_PS + "playstation5_button_mute.png")
const PS_DPAD_UP: Texture2D = preload(ASSET_PATH_PS + "playstation_dpad_up.png")
const PS_DPAD_DOWN: Texture2D = preload(ASSET_PATH_PS + "playstation_dpad_down.png")
const PS_DPAD_LEFT: Texture2D = preload(ASSET_PATH_PS + "playstation_dpad_left.png")
const PS_DPAD_RIGHT: Texture2D = preload(ASSET_PATH_PS + "playstation_dpad_right.png")
const PS_DPAD: Texture2D = preload(ASSET_PATH_PS + "playstation_dpad.png")
const PS_STICK_L: Texture2D = preload(ASSET_PATH_PS + "playstation_stick_l.png")
const PS_STICK_R: Texture2D = preload(ASSET_PATH_PS + "playstation_stick_r.png")
const PS_STICK_L_PRESS: Texture2D = preload(ASSET_PATH_PS + "playstation_stick_l_press.png")
const PS_STICK_R_PRESS: Texture2D = preload(ASSET_PATH_PS + "playstation_stick_r_press.png")
