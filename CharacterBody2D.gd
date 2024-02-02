extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const FRICTION = 6.0
const DASH_SPEED = 800.0
const DASH_COOLDOWN = 1.0  # Set your desired cooldown time in seconds

const MAX_JUMPS = 1
var jumps = 0
@export var double_jump_multiplier = 1.5 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity_multiplier = 1.7

@export var sliding_speed = 1.8
@export var slope_friction = 0.2  # Adjust this value for slope friction
var is_sliding = false

var dash_cooldown_timer = 0.0
var is_dashing = false

func _physics_process(delta):
	var input_vector = Vector2()
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	input_vector = input_vector.normalized()
	
	if is_dashing:
		# Apply dash velocity for a short duration
		velocity.x = input_vector.x * DASH_SPEED
		dash_cooldown_timer = 0
		is_dashing = false
	else:
		# Normal movement logic
		velocity.x = lerp(velocity.x, input_vector.x * SPEED, FRICTION * delta)

	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
			jumps = 0
	
	if is_on_floor():
		if abs(get_floor_normal().x) > 0.5:
			# Reduce friction on slopes
			velocity.x = lerp(
				velocity.x,
				get_floor_normal().x * SPEED * sliding_speed,
				FRICTION * delta * slope_friction  # Apply less friction on slopes
			)
			is_sliding = true
		else:
			is_sliding = false

	else:
		if Input.is_action_just_pressed("ui_up") and jumps < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY * double_jump_multiplier
			jumps += 1

	if Input.is_action_just_pressed("ui_select") and dash_cooldown_timer <= 0.0:
		is_dashing = true
		dash_cooldown_timer = DASH_COOLDOWN

	move_and_slide()
