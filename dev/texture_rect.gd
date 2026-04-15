extends TextureRect

## How far to ray cast to check if the sun is visible
const SUN_RAYCAST_LENGTH: float = 750.0

## The sun that the lens flare follows
@export var sun: DirectionalLight3D

var camera: Camera3D


func _ready() -> void:
	camera = get_viewport().get_camera_3d()


func _physics_process(_delta: float) -> void:
	if not sun or not camera:
		visible = false
		return

	var effective_sun_direction: Vector3 = (
		(sun.global_transform.basis.z * maxf(camera.near, 1.0)) + camera.global_position
	)

	# turn off the lens flare the the sun isn't visible at all
	visible = not camera.is_position_behind(effective_sun_direction)

	if visible:
		# OPTIONAL: hide the lens flare if the sun is blocked
		if not _can_see_sun():
			visible = false
			return

		var sun_screen_position := camera.unproject_position(effective_sun_direction)
		(material as ShaderMaterial).set_shader_parameter("sun_position", sun_screen_position)


## Uses a ray cast to see if anything is blocking the sun
func _can_see_sun() -> bool:
	if not sun or not camera:
		return false

	var origin := camera.global_position
	var end := origin + sun.global_basis.z * SUN_RAYCAST_LENGTH

	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var result := space_state.intersect_ray(query)

	return result.is_empty()
