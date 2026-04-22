extends RichTextLabel

func _ready() -> void:
	GLOBAL.subtitle = self
	GLOBAL.subtitle_progress = $"../../Progress/RadialProgress"
	GLOBAL.subtitle_bg = $"../../Subtitle2/TextureRect"
