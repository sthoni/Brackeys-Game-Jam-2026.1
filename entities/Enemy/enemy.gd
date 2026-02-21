class_name Enemy extends CharacterBody2D

@export var max_speed := 40.0
@export var min_speed := 0.0
@export var avoidance_strength := 3000.0
var current_speed: float

@onready var target: Node2D
@onready var attention_area: Area2D = %AttentionArea
@onready var hitbox: Area2D = %Hitbox
@onready var _raycasts: Node2D = %Raycasts

var in_darkness := true

func _ready() -> void:
	current_speed = max_speed
	attention_area.body_entered.connect(func(body: Node2D) -> void:
		if body is ProtoPlayer:
			target = body
	)
	attention_area.body_exited.connect(func(body: Node2D) -> void:
		if body is ProtoPlayer:
			target = null
	)
	hitbox.area_entered.connect(func(area: Area2D) -> void:
		if area is Flashlight:
			in_darkness = false
	)
	hitbox.area_exited.connect(func(area: Area2D) -> void:
		if area is Flashlight:
			in_darkness = true
	)


func _physics_process(delta: float) -> void:
	if not in_darkness:
		current_speed = lerp(current_speed, min_speed, 0.05)
	else:
		current_speed = lerp(current_speed, max_speed, 0.2)
	if target:
		look_at(target.global_position)
		velocity = position.direction_to(target.global_position) * current_speed + calculate_avoidance_force() * delta
		if position.distance_to(target.global_position) > 10:
			move_and_slide()

func calculate_avoidance_force() -> Vector2:
	var avoidance_force := Vector2.ZERO

	for raycast: RayCast2D in _raycasts.get_children():
		if raycast.is_colliding():
			var collision_position := raycast.get_collision_point()
			var direction_away_from_obstacle := collision_position.direction_to(raycast.global_position)
			var ray_length := raycast.target_position.length()
			var intensity := 1.0 - collision_position.distance_to(raycast.global_position) / ray_length
			var force := direction_away_from_obstacle * intensity
			avoidance_force += force
	return avoidance_force * avoidance_strength
