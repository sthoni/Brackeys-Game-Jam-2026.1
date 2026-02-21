class_name Enemy extends CharacterBody2D

@export var avoidance_strength := 3000.0
@export var stats: EnemyStats
@export var moveset: Attack
@export var step_distance := 15.0

@onready var target: Node2D
@onready var attention_area: Area2D = %AttentionArea
@onready var hurtbox: Area2D = %Hurtbox
@onready var _raycasts: Node2D = %Raycasts
@onready var attack_timer: Timer
@onready var audio: AudioStreamPlayer2D = %AudioStreamPlayer2D

var in_darkness := true
var speed: float
var attack_speed: float
var can_attack := false
var distance_walked := 0.0

func _ready() -> void:
	speed = stats.base_speed
	attack_speed = stats.base_attack_speed
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_speed
	add_child(attack_timer)

	attention_area.body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			target = body
	)
	attention_area.body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			target = null
	)
	hurtbox.area_entered.connect(func(area: Area2D) -> void:
		if area is Flashlight:
			in_darkness = false
	)
	hurtbox.body_entered.connect(func(body: Node2D) -> void:
		print(body)
		if body is Player:
			can_attack = true
	)
	hurtbox.body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			can_attack = false
	)
	hurtbox.area_exited.connect(func(area: Area2D) -> void:
		if area is Flashlight:
			in_darkness = true
	)


func _physics_process(delta: float) -> void:
	if not in_darkness:
		speed = lerp(speed, 0.0, 0.05)
	else:
		speed = lerp(speed, stats.base_speed, 0.2)
	if target:
		look_at(target.global_position)
		velocity = position.direction_to(target.global_position) * speed + calculate_avoidance_force() * delta
		if position.distance_to(target.global_position) > 10:
			if velocity.length() > 0.0:
				distance_walked += velocity.length() * delta
				if distance_walked > step_distance:
					distance_walked = 0.0
					audio.pitch_scale = randf_range(0.6, 1.1)
					audio.play()
			move_and_slide()
	if can_attack:
		attack()

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

func attack() -> void:
	if not attack_timer.is_stopped():
		return
	attack_timer.start()
	var attack_hitbox: Hitbox = moveset.hitbox_scene.instantiate()
	attack_hitbox.damage = moveset.damage
	add_child(attack_hitbox)
	attack_hitbox.position = moveset.offset
	SoundManager.play_sfx(moveset.sound, 0.9)
	await get_tree().create_timer(moveset.attack_duration).timeout
	attack_hitbox.queue_free()
