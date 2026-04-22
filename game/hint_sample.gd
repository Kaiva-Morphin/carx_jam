extends HBoxContainer

func key(text):
	$Key.text = text

func label(text):
	$Label.text = text

func font(f):
	if f:
		$Key.add_theme_font_override("0", f)
	else:
		$Key.remove_theme_font_override("0")

func key_texture(t: Texture2D):
	$KeyTexture.texture = t
