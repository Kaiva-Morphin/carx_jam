extends BoardInspectable
class_name BoardCard

@export var data : Dictionary = {"title": "notitle", "descriptions": []}
var unlocked = []

func inspect():
	var collected = []
	var todo = false
	for d in range(len(data.descriptions)):
		if d in unlocked:
			collected.append(tr(data.descriptions[d].text))
		else:
			todo = true
	if todo:
		collected.append(tr("KEY_BOARD_NOT_ALL"))
	return "\n".join(collected)

func init():
	$Title.text = data.title
	$Image.texture = RUMOR.image(data.image)

func _init() -> void:
	pass

func show_image():
	$Image.show()



func focus():
	$Hover.show()
	$Regular.hide()

func unfocus():
	$Hover.hide()
	$Regular.show()
	
