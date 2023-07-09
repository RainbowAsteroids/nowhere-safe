extends VBoxContainer
class_name LevelWidgets

@export var level_widget_scene: PackedScene

func _ready():
	var i := 0
	while i in RunTimeManager.best_times and i < 4:
		var level_widget: LevelWidget = level_widget_scene.instantiate()
		level_widget.level_num = i
		add_child(level_widget)
		
		i += 1
	
	var level_widget: LevelWidget = level_widget_scene.instantiate()
	level_widget.level_num = i
	add_child(level_widget)
