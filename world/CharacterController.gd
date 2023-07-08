extends Node2D
class_name CharacterController

const walk_force := 650.0
const max_walk_speed := 350.0

const moving_friction := 3.0
const still_friction := 6.0

@export var target: Civilian:
	set(v):
		if target != null:
			target.uncontrol()
		target = v
		target.control()

func _physics_process(delta):
	var body = target.body
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
				target.body.global_position,
				control_target.body.global_position,
				4294967295, # default parameter
				[target.body.get_rid()]
			)
			var result = space_state.intersect_ray(query)
			
			if result != {} and result["collider"] == control_target.body:
				self.target = control_target
