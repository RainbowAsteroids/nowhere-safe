extends Button

func _ready():
	visible = OS.get_name() != "Web"
	disabled = not visible

func _on_pressed():
	get_tree().quit()
