extends Node

var player : CharacterBody3D
var dialog : Control
var hint_node : Label
var interaction_ray : RayCast3D
var inspect_cam : Camera3D
var inspect_node : Node3D
var processor : Node3D

enum GameAct {
	Intro,
	Home,
	Suspect,
	Lab,
	Final
}

#enum Interactable {
	#Dialog,
	#Switch,
	#Car
#}
#
#func hint(i: Interactable):
	#match i:
		#Interactable.Dialog: return "E - Talk"
		#Interactable.Switch: return "E - Use"
		#Interactable.Car: return "E - Drive"
	#return "UNK"

var interacted_now = false

func _process(_dt: float) -> void:
	if !interaction_ray: return
	var c = interaction_ray.get_collider()
	player.dbg("COL", c)
	GLOBAL.hint_node.hide()
	if c && c.is_in_group("interactible") && !interacted_now:
		#var nearest = c.interaction_record
		GLOBAL.hint_node.show()
		GLOBAL.hint_node.text = c.hint()
		if Input.is_action_just_pressed("interact"):
			c.interact()
			#player.process_mode = Node.PROCESS_MODE_DISABLED
			#nearest.node.interact()
			#interacted_now = true
			#interact_record = nearest
			#nearest.node.end_interaction.connect(end)
	pass
	#var nearest = null
	#var best_score = -INF
	#
	#for key in interactables:
		#var record = interactables[key]
		#var node = record.node
		#var to_point = node.global_position - player.camera.global_position
		#var dist = to_point.length()
		#if dist == 0:
			#continue
		#var dir = to_point / dist
		#var forward = -player.camera.global_transform.basis.z
		#var dot = dir.dot(forward)
		#var threshold = 0.8
		#if dot > threshold:
			#var score = dot - dist * 0.01
			#if score > best_score:
				#best_score = score
				#nearest = record
	#if nearest && !interacted_now:
		#GLOBAL.hint_node.show()
		#GLOBAL.hint_node.text = hint(nearest.type)
		#if Input.is_action_just_pressed("interact"):
			#player.process_mode = Node.PROCESS_MODE_DISABLED
			#nearest.node.interact()
			#interacted_now = true
			#interact_record = nearest
			##nearest.node.end_interaction.connect(end)
	#else:
		#GLOBAL.hint_node.hide()

var interact_record = null

#func interaction_end():
	#unblock_player()
	#var node = interact_record.node
	#var type = interact_record.type
	#interacted_now = false
	
	#match type:
		#Interactable.Dialog:
			#pass
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#(func(): player.process_mode = Node.PROCESS_MODE_INHERIT).call_deferred()

var player_blocked = false
func block_player():
	player_blocked = true
	player.process_mode = Node.PROCESS_MODE_DISABLED

func unblock_player():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	player_blocked = false
	(func(): player.process_mode = Node.PROCESS_MODE_INHERIT).call_deferred()


class Interactable extends Area3D:
	signal interaction_start
	signal interaction_end
	
	func _ready() -> void:
		pass
	
	func hint() -> String:
		return ""
	
	func interact() -> void:
		interaction_start.emit()

class Inspectable extends Interactable:
	pass
