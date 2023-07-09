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

enum Direction {
	Left,
	Right,
	Up,
	Down
}

const walk_speed := 75.0
const suspicion_clock_end := 0.75

@export var body: CharacterBody2D
@export var nav_agent: NavigationAgent2D

@export var uncontrolled_sprite: AnimatedSprite2D
@export var controlled_sprite: AnimatedSprite2D

@export var bang_sprite: Sprite2D
@export var interro_sprite: Sprite2D

@export var stun_timer: Timer
@export var suspicious_timer: Timer
@export var weapon := Weapon.Melee

@export var target_light: PointLight2D
@export var controlled_light: PointLight2D

var state := State.Default:
	set(v):
		match state: # on-exit state
			State.Suspicious:
				suspicion_clock = 0.0
				suspicious_timer.stop()
				bang_sprite.visible = false
			State.Stunned:
				interro_sprite.visible = false
			State.Confused:
				interro_sprite.visible = false
			State.Controlled:
				controlled_light.visible = false
			_:
				pass
		
		match v: # on-enter state
			State.Default:
				body.position = Vector2.ZERO
			State.Confused:
				nav_agent.target_position = global_position
				interro_sprite.visible = true
			State.Stunned:
				interro_sprite.visible = true
			State.Suspicious:
				bang_sprite.visible = true
			State.Controlled:
				controlled_light.visible = true
			_:
				pass
		
		state = v

var hover := false:
	set(v):
		hover = v
		target_light.visible = hover

var near_target := false

var suspicion_clock := 0.0

@onready var prev_position := position
@onready var prev_body_position := body.position

func update_sprite_direction(direction: Direction):
	for sprite in [uncontrolled_sprite, controlled_sprite]:
		sprite.flip_h = direction == Direction.Left
		match direction:
			Direction.Up:
				sprite.animation = "back"
			Direction.Down:
				sprite.animation = "front"
			Direction.Left, Direction.Right:
				sprite.animation = "side"

func _process(_delta):
	if state == State.Controlled:
		uncontrolled_sprite.visible = false
		controlled_sprite.visible = true
	else:
		uncontrolled_sprite.visible = true
		controlled_sprite.visible = false
	
	var direction: Vector2
	match state:
		State.Default:
			direction = position - prev_position
		_:
			direction = body.position - prev_body_position
	
	if direction.length() < 0.001: return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			update_sprite_direction(Direction.Right)
		else:
			update_sprite_direction(Direction.Left)
	else:
		if direction.y >= 0:
			update_sprite_direction(Direction.Down)
		else:
			update_sprite_direction(Direction.Up)
	
	prev_position = position
	prev_body_position = body.position

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

#func _draw():
#	var color: Color
#	match state:
#		State.Controlled:
#			color = Color.ORANGE
#		State.Suspicious:
#			color = Color.RED
#		_:
#			match weapon:
#				Weapon.Melee:
#					color = Color.WHITE
#				Weapon.Taser:
#					color = Color.YELLOW
#				Weapon.Gun:
#					color = Color.BLACK
#
#	draw_circle(
#		body.position, 
#		15, 
#		color
#	)
#
#	draw_arc(
#		body.position, 
#		15, 
#		0, 
#		PI * 2, 
#		16, 
#		Color.CYAN if hover else color, 
#		2, 
#		true
#	)

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
