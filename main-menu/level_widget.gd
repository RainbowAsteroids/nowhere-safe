extends PanelContainer
class_name LevelWidget

@export var time_label: Label
@export var title: Label

var level_num: int

func _ready():
	title.text = title.text.format([level_num + 1])
	
	if level_num in RunTimeManager.best_times:
		time_label.text = time_label.text.format([
			RunTimeManager.format_time(RunTimeManager.best_times[level_num])
		])
	else:
		time_label.visible = false

func _on_button_pressed():
	get_tree().change_scene_to_file("res://world/worlds/{0}.tscn".format([level_num]))
