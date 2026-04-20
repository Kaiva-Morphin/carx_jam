extends Node3D

@export var max_angle := deg_to_rad(90.0)
@onready var a := $A
@onready var b := $B
@onready var close := $CLOSE
@onready var door := $Door
var opened = false
var target_angle = 0.0

func _ready() -> void:
	a.body_entered.connect(on_a_in)
	b.body_entered.connect(on_b_in)
	close.body_exited.connect(on_c_out)

func _process(delta: float) -> void:
	door.rotation.y = lerp(door.rotation.y, target_angle, delta * 10.0)

func on_a_in(_b):
	if !_b.is_in_group("player"): return
	if target_angle != 0.0: return
	target_angle = max_angle

func on_b_in(_b):
	if !_b.is_in_group("player"): return
	if target_angle != 0.0: return
	target_angle = -max_angle

func on_c_out(_b):
	if !_b.is_in_group("player"): return
	target_angle = 0.0
