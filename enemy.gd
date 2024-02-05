extends CharacterBody2D

@export var gravity_multiplier = 1.7
@export var enemy_speed = 15.0
@export var patrol_speed = 5.0
@export var patrol_distance = 100.0

@onready var player = get_node("../player")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_player_on_radius = false

var patrols = []
var current_patrol_index = 0

var patrol_direction = 1

func _ready():
	for patrol in get_node("patrol").get_children():
		patrols.append(patrol.global_position)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta
	
	velocity = Vector2.ZERO
	if player and is_player_on_radius:
		velocity = velocity.direction_to(player.position) * enemy_speed
	else:
		if patrols.size() > 0:
			var target_position = patrols[current_patrol_index]
			if position.distance_to(target_position) < 10:
				current_patrol_index += 1
				if current_patrol_index >= patrols.size():
					current_patrol_index = 0 # Loop back to the first patrol
			else:
				velocity.x = position.direction_to(target_position).x * patrol_speed
		
	position += velocity * delta
	move_and_slide()

func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	if body.name == "player":
		is_player_on_radius = true

func _on_area_2d_body_exited(body):
	is_player_on_radius = false
