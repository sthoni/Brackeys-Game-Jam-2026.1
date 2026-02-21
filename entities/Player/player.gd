class_name Player extends CharacterBody2D

var speed: float
var stamina: float
@export var stats: CharacterStats

@onready var health_component: HealthComponent = %HealthComponent
@onready var hurtbox: Area2D = %Hurtbox

func _ready() -> void:
	health_component.init_health(stats.max_health)
	speed = stats.base_speed
	stamina = stats.base_stamina

	health_component.health_changed.connect(func(health: int) -> void:
		SignalBus.emit_signal("player_stats_changed", health, stamina)
	)
	health_component.health_depleted.connect(func() -> void:
		die()
	)

func get_input() -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

# TODO: Taschenlampen-Logik in Komponente und geschmeidig machen
func rotate_to_mouse(delta: float) -> void:
	rotation += get_angle_to(get_global_mouse_position()) * 3.0 * delta

func _physics_process(delta: float) -> void:
	get_input()
	rotate_to_mouse(delta)
	move_and_slide()

func die() -> void:
	GameManager.reload_scene()
