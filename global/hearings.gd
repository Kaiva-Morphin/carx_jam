extends Node

class Progressive:
	var key: String
	var value: String
	var unlocked: bool

class Hearing:
	var key: String
	var title: String
	var descriptions: Array[Progressive]
	var connections: Array[Progressive]
	var position: Vector2
	var image: ImageTexture
	var image_trigger: String

#var h_hearings = {
	#"key_body": Hearing {
		#
	#}
#}
