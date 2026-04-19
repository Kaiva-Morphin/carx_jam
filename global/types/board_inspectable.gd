extends Area2D
class_name BoardInspectable


func inspect():
	return "abstract"

func _init() -> void:
	pass

func focus():
	$Hover.show()
	$Regular.hide()

func unfocus():
	$Hover.hide()
	$Regular.show()
	
