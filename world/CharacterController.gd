extends Node2D
class_name CharacterController

signal win
signal lose

const walk_force := 650.0
const max_walk_speed := 350.0

const moving_friction := 3.0
const still_friction := 6.0

const charge_attack_time := 1.5

const aim_color := Color.RED
const shoot_color := Color.YELLOW

const mega_mask := 4294967295

@export var controlled: Civilian:
	set(v):
		if controlled != null:
			controlled.uncontrol()
		controlled = v
		controlled.control()

@export var target: Target

var charge_attack_clock := 0.0

func gun_cast() -> Dictionary:
	const cast_length := 2000
	var space_state := get_world_2d().direct_space_state
	var start_pos = controlled.body.global_position
	var direction := (get_global_mouse_position() - start_pos).normalized()

	var query := PhysicsRayQueryParameters2D.create(
		start_pos,
		start_pos + (direction * cast_length),
		mega_mask,
		[controlled.body.get_rid()]
	)
	return space_state.intersect_ray(query)

func _draw():
	if controlled.weapon == Civilian.Weapon.Gun:
		var cast_result = gun_cast()
		
		draw_line(
			controlled.body.global_position,
			cast_result["position"],
			shoot_color if Input.is_action_pressed("attack") else aim_color,
			2.0,
			true
		)

func _process(delta):
	queue_redraw()
	
	var can_attack = controlled.near_target or controlled.weapon == Civilian.Weapon.Gun
	if Input.is_action_pressed("attack") and can_attack:
		match controlled.weapon:
			Civilian.Weapon.Taser:
				win.emit()
				get_tree().paused = true
			Civilian.Weapon.Melee:
				charge_attack_clock += delta
				
				var space_state = get_world_2d().direct_space_state
				var civilians = get_tree().get_nodes_in_group("civilian")
				for civilian in civilians:
					if civilian != controlled and civilian is Civilian:
						var query = PhysicsRayQueryParameters2D.create(
							controlled.body.global_position,
							civilian.body.global_position,
							mega_mask,
							[controlled.body.get_rid()]
						)
						var result = space_state.intersect_ray(query)
						
						if result != {} and result["collider"] == civilian.body:
							civilian.suspicion_tick(delta)
				
				if charge_attack_clock >= charge_attack_time:
					win.emit()
					get_tree().paused = true
			Civilian.Weapon.Gun:
				var result = gun_cast()
				var success: bool = result != {} and result["collider"] == target
				
				if success:
					win.emit()
				else:
					lose.emit()
				
				get_tree().paused = true
			_:
				push_error("Weapon '{0}' not implemented".format([controlled.weapon]))
	else:
		charge_attack_clock = 0.0

func _physics_process(delta):
	var body = controlled.body
	var acceleration = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		acceleration += Vector2.LEFT * walk_force
	if Input.is_action_pressed("move_right"):
		acceleration += Vector2.RIGHT * walk_force
	if Input.is_action_pressed("move_up"):
		acceleration += Vector2.UP * walk_force
	if Input.is_action_pressed("move_down"):
		acceleration += Vector2.DOWN * walk_force
	
	if acceleration == Vector2.ZERO:
		body.velocity = lerp(body.velocity, Vector2.ZERO, still_friction * delta)
	else:
		body.velocity = lerp(body.velocity, Vector2.ZERO, moving_friction * delta)
	body.velocity += acceleration * delta
	
	body.velocity = body.velocity.normalized() * min(body.velocity.length(), max_walk_speed)
	
	body.move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("control"):
		var control_targets = get_tree().get_nodes_in_group("civilian") \
			.filter(func(node): return node.hover)
		
		if control_targets != []:
			var control_target = control_targets[0]
			
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(
				controlled.body.global_position,
				control_target.body.global_position,
				mega_mask, # default parameter
				[controlled.body.get_rid()]
			)
			var result = space_state.intersect_ray(query)
			
			if result != {} and result["collider"] == control_target.body:
				self.controlled = control_target
