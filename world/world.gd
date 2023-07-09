extends Node2D
class_name World

@export var win_screen: CanvasLayer
@export var lose_screen: CanvasLayer

@export var current_time: Label
@export var best_time: Label
@export var best_time_indicator: Control

var world_num := -1
var start_time := Time.get_ticks_msec()
var duration: float

func lose():
	print("lose")
	
	lose_screen.visible = true
	get_tree().paused = true

func win():
	print("win")
	duration = float(Time.get_ticks_msec() - start_time) / 1000.0
	
	current_time.text = "Time: {0}".format([
		RunTimeManager.format_time(duration)
	])
	if world_num in RunTimeManager.best_times:
		best_time.text = "Best time: {0}".format([
			RunTimeManager.format_time(RunTimeManager.best_times[world_num])
		])
		
		if duration < RunTimeManager.best_times[world_num]:
			best_time_indicator.visible = true
			RunTimeManager.best_times[world_num] = duration
			RunTimeManager.sync()
	else:
		best_time.visible = false
		RunTimeManager.best_times[world_num] = duration
		RunTimeManager.sync()
	
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
