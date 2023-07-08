@tool
extends PathFollow2D
class_name Civilian

enum State {
	Default,
	Stunned,
	Confused,
	Controlled
}

@export var body: CharacterBody2D
@export var nav_agent: NavigationAgent2D
@export var stun_timer: Timer
var state := State.Default

var hover := false

const walk_speed := 75.0

func _process(_delta):
	queue_redraw()

func _physics_process(delta):
	if not Engine.is_editor_hint():
		match state:
			State.Default:
				print("default")
				progress += walk_speed * delta
			State.Controlled:
				pass
			State.Stunned:
				print("stunned")
				pass
			State.Confused:
				var target := nav_agent.get_next_path_position()
				var direction := body.global_position.direction_to(target)
				print("confused", target, global_position, direction)
				
				body.velocity = lerp(body.velocity, direction * walk_speed, 3.0 * delta)
				body.move_and_slide()
				
				if nav_agent.is_navigation_finished():
					state = State.Default
					body.position = Vector2.ZERO
			_:
				push_error("State '{0}' not implemented".format([state]))

func _draw():
	var color = Color.WHITE if state != State.Controlled else Color.ORANGE
	
	draw_circle(
		body.position, 
		15, 
		color
	)
	
	draw_arc(
		body.position, 
		15, 
		0, 
		PI * 2, 
		16, 
		Color.CYAN if hover else color, 
		2, 
		true
	)

func control():
	self.state = State.Controlled
	stun_timer.stop()
	body.velocity = Vector2.ZERO

func uncontrol():
	self.state = State.Stunned
	stun_timer.start()
	body.velocity = Vector2.ZERO

func _on_stun_timer_timeout():
	self.state = State.Confused
	
	nav_agent.target_position = global_position

func _on_character_body_2d_mouse_entered():
	hover = state != State.Controlled

func _on_character_body_2d_mouse_exited():
	hover = false
