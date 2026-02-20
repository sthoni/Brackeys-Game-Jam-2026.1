class_name ProtoEnemy extends CharacterBody2D

@export var max_speed := 40.0
@export var min_speed := 20.0
var current_speed: float

@onready var target: Node2D
@onready var attention_area: Area2D = %AttentionArea
@onready var hitbox: Area2D = %Hitbox

var in_darkness := true

func _ready() -> void:
	current_speed = max_speed
	attention_area.body_entered.connect(func(body: PhysicsBody2D) -> void:
		if body is ProtoPlayer:
			target = body
	)
	attention_area.body_exited.connect(func(body: PhysicsBody2D) -> void:
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


func _physics_process(_delta: float) -> void:
	if not in_darkness:
		current_speed = lerp(current_speed, min_speed, 0.1)
	else:
		current_speed = lerp(current_speed, max_speed, 0.2)
	if target:
		velocity = position.direction_to(target.global_position) * current_speed
		if position.distance_to(target.global_position) > 10:
			move_and_slide()
