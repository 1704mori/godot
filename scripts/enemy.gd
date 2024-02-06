extends CharacterBody2D

@export var gravity_multiplier = 1.7
@export var enemy_speed = 1
@export var patrol_speed = 5.0
@export var patrol_distance = 100.0

@onready var player = get_node("../player")
@onready var sprite = $Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_player_on_radius = false

var patrols = []
var current_patrol_index = 0

var player_jumps = 0

func _ready():
	for patrol in get_node("patrol").get_children():
		patrols.append(patrol.global_position)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta
		
	if abs(velocity.x) > 0:
		$AnimationPlayer.play("Run")
	
	if velocity.x > 0:
		sprite.scale.x = abs(sprite.scale.x)
	elif velocity.x < 0:
		sprite.scale.x = abs(sprite.scale.x) * -1
	
	if player and is_player_on_radius:
		velocity.x = (player.position.x - position.x) * enemy_speed
		if player.jumps == 1:
			velocity.y = (player.position.y - position.y) * gravity * gravity_multiplier * delta + 355

	move_and_slide()

func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	if body.name == "player":
		is_player_on_radius = true

func _on_area_2d_body_exited(body):
	is_player_on_radius = false
