extends Node2D
class_name World

func lose():
	print("lose")
	get_tree().paused = true

func win():
	print("win")
	get_tree().paused = true

func _ready():
	for civilian in get_tree().get_nodes_in_group("civilian"):
		if civilian is Civilian:
			civilian.detected_player.connect(lose)

func _on_character_controller_lose():
	lose()

func _on_character_controller_win():
	win()
