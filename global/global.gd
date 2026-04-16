extends Node

var player : CharacterBody3D
var dialog : Control
var hint_node : Label
var interaction_ray : RayCast3D

enum Interactable {
	Dialog,
	Switch,
	Car
}

func hint(i: Interactable):
	match i:
		Interactable.Dialog: return "E - Talk"
		Interactable.Switch: return "E - Use"
		Interactable.Car: return "E - Drive"
	return "UNK"

var interactables = {
	
}

var interacted_now = false

func _process(_dt: float) -> void:
	var c = interaction_ray.get_collider()
	if c && c.is_in_group("interactable") && !interacted_now:
		var nearest = c.interaction_record
		GLOBAL.hint_node.show()
		GLOBAL.hint_node.text = hint(nearest.type)
		if Input.is_action_just_pressed("interact"):
			player.process_mode = Node.PROCESS_MODE_DISABLED
			nearest.node.interact()
			interacted_now = true
			interact_record = nearest
			nearest.node.end_interaction.connect(end)
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
			#nearest.node.end_interaction.connect(end)
	else:
		GLOBAL.hint_node.hide()

var interact_record = null

func end():
	var node = interact_record.node
	var type = interact_record.type
	node.end_interaction.disconnect(end)
	interacted_now = false
	match type:
		Interactable.Dialog:
			pass
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	(func(): player.process_mode = Node.PROCESS_MODE_INHERIT).call_deferred()


func on_interaction_hit(area: Area3D):
	if !area.is_in_group("interactable"): return
	
