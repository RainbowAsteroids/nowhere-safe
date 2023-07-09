@tool
extends StaticBody2D
class_name Target

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var attacked := false:
	set(v):
		attacked = v
		sprite.animation = "scared" if v else "default"

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _on_area_2d_body_entered(body):
	if body.get_parent() is Civilian:
		body.get_parent().near_target = true

func _on_area_2d_body_exited(body):
	if body.get_parent() is Civilian:
		body.get_parent().near_target = false
