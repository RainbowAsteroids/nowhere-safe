@tool
extends StaticBody2D
class_name Target

func _draw():
	var color := Color.DARK_GOLDENROD
	draw_circle(Vector2.ZERO, 15, color)
	draw_arc(Vector2.ZERO, 15, 0, TAU, 16, color, 1, true)

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _on_area_2d_body_entered(body):
	if body.get_parent() is Civilian:
		body.get_parent().near_target = true

func _on_area_2d_body_exited(body):
	if body.get_parent() is Civilian:
		body.get_parent().near_target = false
