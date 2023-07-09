@tool
extends PathFollow2D
class_name Civilian

signal detected_player

enum State {
	Default,
	Stunned,
	Confused,
	Controlled,
	Suspicious
}

enum Weapon {
	Melee,
	Taser,
	Gun
}

const walk_speed := 75.0
const suspicion_clock_end := 0.75

@export var body: CharacterBody2D
@export var nav_agent: NavigationAgent2D
@export var stun_timer: Timer
@export var suspicious_timer: Timer
@export var weapon := Weapon.Melee

var state := State.Default:
	set(v):
		match v: # on-enter state
			State.Default:
				body.position = Vector2.ZERO
			State.Confused:
				nav_agent.target_position = global_position
			_:
				pass
		
		match state: # on-exit state
			State.Suspicious:
				suspicion_clock = 0.0
				suspicious_timer.stop()
			_:
				pass
		
		state = v

var hover := false
var near_target := false

var suspicion_clock := 0.0

func _process(_delta):
	queue_redraw()

func _physics_process(delta):
	if not Engine.is_editor_hint():
		match state:
			State.Default:
				progress += walk_speed * delta
			State.Controlled:
				pass
			State.Stunned:
				pass
			State.Suspicious:
				pass
			State.Confused:
				var target := nav_agent.get_next_path_position()
				var direction := body.global_position.direction_to(target)
				
				body.velocity = lerp(body.velocity, direction * walk_speed, 3.0 * delta)
				body.move_and_slide()
				
				if nav_agent.is_navigation_finished():
					self.state = State.Default
			_:
				push_error("State '{0}' not implemented".format([state]))

func _draw():
	var color: Color
	match state:
		State.Controlled:
			color = Color.ORANGE
		State.Suspicious:
			color = Color.RED
		_:
			match weapon:
				Weapon.Melee:
					color = Color.WHITE
				Weapon.Taser:
					color = Color.YELLOW
				Weapon.Gun:
					color = Color.BLACK
	
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

func _on_character_body_2d_mouse_entered():
	hover = state != State.Controlled

func _on_character_body_2d_mouse_exited():
	hover = false

func suspicion_tick(delta):
	suspicious_timer.start()
	suspicion_clock += delta
	if state != State.Suspicious:
		self.state = State.Suspicious
	
	if suspicion_clock >= suspicion_clock_end:
		detected_player.emit()

func _on_suspicious_timer_timeout():
	self.state = State.Confused
