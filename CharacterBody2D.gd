extends CharacterBody2D

# Constants for movement
const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const FRICTION = 6.0
const DASH_SPEED = 800.0
const DASH_COOLDOWN = 1.0
const WALL_JUMP_TIME = 0.2
const MAX_JUMPS = 1
const COYOTE_TIME = 0.6  # Coyote time duration in seconds

# Exported variables for tweaking in the editor
@export var double_jump_multiplier = 1.2
@export var gravity_multiplier = 1.7
@export var sliding_speed = 1.8
@export var slope_friction = 0.2

# Internal state variables
var jumps = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var input_vector = Vector2()
var is_dashing = false
var dash_cooldown_timer = 0.0
var can_wall_jump = false
var wall_jump_timer = 0.0
var facing_right = true
var just_landed = false
var was_in_air = false
var was_on_floor = false
var is_landing = false
var coyote_time_timer = 0.0  # Timer for coyote time
var is_sliding = false

# Node references
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _physics_process(delta):
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	input_vector = input_vector.normalized()

	# Flip sprite based on movement direction
	if input_vector.x < 0:
		sprite.flip_h = true
		$CollisionShape2D.position.x = sprite.scale.x / 2 + 48
	elif input_vector.x > 0:
		sprite.flip_h = false
		$CollisionShape2D.position.x = sprite.scale.x / 2 - 48
		
	if is_dashing:
		velocity.x = input_vector.x * DASH_SPEED
		dash_cooldown_timer = 0
		is_dashing = false
	else:
		velocity.x = lerp(velocity.x, input_vector.x * SPEED, FRICTION * delta)

	if is_on_floor():
		if abs(get_floor_normal().x) > 0.5:
			velocity.x = lerp(velocity.x, get_floor_normal().x * SPEED * sliding_speed, FRICTION * delta * slope_friction)
			is_sliding = true
		else:
			is_sliding = false
			can_wall_jump = false

	if Input.is_action_just_pressed("ui_select") and dash_cooldown_timer <= 0.0:
		is_dashing = true
		dash_cooldown_timer = DASH_COOLDOWN

	# Coyote time logic
	if is_on_floor():
		coyote_time_timer = COYOTE_TIME
	elif not is_on_floor() and coyote_time_timer > 0:
		coyote_time_timer -= delta

	handle_movement_and_jumping(delta)

	was_on_floor = is_on_floor()
	was_in_air = not is_on_floor()
	move_and_slide()
	just_landed = is_on_floor() and was_in_air
	handle_animation()

func handle_movement_and_jumping(delta):
	if not is_on_floor() and not Input.is_action_just_pressed("ui_up"):
		velocity.y += gravity * gravity_multiplier * delta
		wall_jump_timer = 0
		animation_player.play("Fall")

	if (is_on_floor() or coyote_time_timer > 0) and Input.is_action_just_pressed("ui_up"):
		if not is_on_floor():
			coyote_time_timer = 0  # Reset coyote time if used for jumping
			velocity.y = 0  # Reset or reduce vertical velocity before jumping
		velocity.y = JUMP_VELOCITY * (1.0 + (COYOTE_TIME - coyote_time_timer) * 0.2)  # Slightly increase jump velocity based on remaining coyote time
		jumps = 0
		animation_player.play("Jump")
	elif not is_on_floor() and Input.is_action_just_pressed("ui_up") and jumps < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY * double_jump_multiplier
		jumps += 1
		animation_player.play("Jump")

func handle_animation():
	if just_landed and not is_landing:
		is_landing = true
		#animation_player.play("Land")
		
	elif is_on_floor(): #and not is_landing:
		if abs(input_vector.x) > 0:
			animation_player.play("Run")
		else:
			animation_player.play("Idle")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Land":
		is_landing = false

# Remember to connect the _on_animation_player_animation_finished signal to this method in the Godot editor
