class_name ProtoPlayer extends CharacterBody2D

@export var speed := 200.0
@export var stamina := 100.0

@onready var hitbox: Area2D = %Hitbox2
var is_on_exit := false

func _ready() -> void:
	hitbox.area_entered.connect(func(area: Area2D) -> void:
		print(area)
		if area is ExitArea:
			is_on_exit = true
	)
	hitbox.area_exited.connect(func(area: Area2D) -> void:
		if area is ExitArea:
			is_on_exit = false
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

func _input(event: InputEvent) -> void:
	if is_on_exit and event.is_action_pressed("interact"):
		print('Hallo')
		GameManager.change_scene(preload("res://ui/EndMenu.tscn"))
