extends Node3D


var initial_rotaion := Vector3.ZERO
@onready var person = $Person

func _ready() -> void:
	initial_rotaion = rotation

func _process(dt: float) -> void:
	if !player:
		return
	person.look_at(Vector3(player.position.x, person.position.y, player.position.z), Vector3.UP, true)
	

var player = null


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	player = null
