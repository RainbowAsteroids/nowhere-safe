extends Node2D
class_name World

@export var win_screen: CanvasLayer
@export var lose_screen: CanvasLayer

var world_num := -1

func lose():
	print("lose")
	
	lose_screen.visible = true
	get_tree().paused = true

func win():
	print("win")
	
	win_screen.visible = true
	get_tree().paused = true
	

func _ready():
	for civilian in get_tree().get_nodes_in_group("civilian"):
		if civilian is Civilian:
			civilian.detected_player.connect(lose)
	
	var regex := RegEx.new()
	regex.compile("res:\\/\\/world\\/worlds\\/([0-9]+)\\.tscn")
	var result := regex.search(scene_file_path)
	if result:
		world_num = int(result.strings[1])

func _on_character_controller_lose():
	lose()

func _on_character_controller_win():
	win()

func _on_next_level_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://world/worlds/{0}.tscn".format([world_num + 1]))


func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
