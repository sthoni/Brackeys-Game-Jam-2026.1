class_name Player extends CharacterBody2D

enum PlayerState {
	GROUND,
	JUMP,
	DOUBLE_JUMP,
	FALL
}

const MAX_JUMPS := 2

@export var acceleration := 700.0
@export var deceleration := 1400.0
@export var max_speed := 120.0
@export var air_acceleration := 500.0
@export var max_fall_speed := 250.0

@export_category("Jump")
@export_range(10.0, 200.0) var jump_height := 50.0
@export_range(0.1, 1.5) var jump_time_to_peak := 0.37
@export_range(0.1, 1.5) var jump_time_to_descent := 0.2
@export_range(50.0, 200.0) var jump_horizontal_distance := 80.0

@export_range(5.0, 50.0) var jump_cut_divider := 15.0

@export_category("Double Jump")
@export_range(10.0, 200.0) var double_jump_height := 30.0
@export_range(0.1, 1.5) var double_jump_time_to_peak := 0.3
@export_range(0.1, 1.5) var double_jump_time_to_descent := 0.25

var direction_x := 0.0
var current_state: PlayerState = PlayerState.GROUND
var current_gravity := 0.0

# State-specific variables
var jump_count := 0

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var dust: GPUParticles2D = %Dust
@onready var coyote_timer := Timer.new()

# Primary jump calculations
@onready var jump_speed := calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity := calculate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity := calculate_fall_gravity(jump_height, jump_time_to_descent)
@onready var jump_horizontal_speed := calculate_jump_horizontal_speed(jump_horizontal_distance, jump_time_to_peak, jump_time_to_descent)

# Double jump calculations
@onready var double_jump_speed := calculate_jump_speed(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_gravity := calculate_jump_gravity(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_fall_gravity := calculate_fall_gravity(double_jump_height, double_jump_time_to_descent)


func _ready() -> void:
	_transition_to_state(current_state)

	coyote_timer.wait_time = 0.1
	coyote_timer.one_shot = true
	add_child(coyote_timer)


func _physics_process(delta: float) -> void:
	direction_x = signf(Input.get_axis("move_left", "move_right"))

	match current_state:
		PlayerState.GROUND:
			process_ground_state(delta)
		PlayerState.JUMP:
			process_jump_state(delta)
		PlayerState.FALL:
			process_fall_state(delta)
		PlayerState.DOUBLE_JUMP:
			process_double_jump_state(delta)

	velocity.y += current_gravity * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	move_and_slide()


## Calculates the maximum horizontal speed based on jump parameters
func calculate_jump_horizontal_speed(distance: float, time_to_peak: float, time_to_descent: float) -> float:
	return distance / (time_to_peak + time_to_descent)


## Calculates the initial jump velocity needed to reach a certain height
## Returns a negative value so you can directly apply it to velocity.y
func calculate_jump_speed(height: float, time_to_peak: float) -> float:
	return (-2.0 * height) / time_to_peak


## Calculates the gravity to apply while rising during a jump to reach the desired height
func calculate_jump_gravity(height: float, time_to_peak: float) -> float:
	return (2.0 * height) / pow(time_to_peak, 2.0)


## Calculates the gravity to apply while falling to get a consistent parabolic jump that matches the desired height
func calculate_fall_gravity(height: float, time_to_descent: float) -> float:
	return (2.0 * height) / pow(time_to_descent, 2.0)


func process_ground_state(delta: float) -> void:
	var is_moving := absf(direction_x) > 0.0
	if is_moving:
		velocity.x += acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)

		animated_sprite.flip_h = direction_x < 0.0
		animated_sprite.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		animated_sprite.play("Idle")

	dust.emitting = is_moving

	if Input.is_action_just_pressed("jump"):
		_transition_to_state(PlayerState.JUMP)
	elif not is_on_floor():
		_transition_to_state(PlayerState.FALL)


func process_jump_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		animated_sprite.flip_h = direction_x < 0.0

	if Input.is_action_just_released("jump"):
		var jump_cut_speed := jump_speed / jump_cut_divider
		if velocity.y < 0.0 and velocity.y < jump_cut_speed:
			velocity.y = jump_cut_speed

	if velocity.y >= 0.0:
		_transition_to_state(PlayerState.FALL)
	elif Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		_transition_to_state(PlayerState.DOUBLE_JUMP)


func process_double_jump_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		animated_sprite.flip_h = direction_x < 0.0

	if velocity.y >= 0.0:
		_transition_to_state(PlayerState.FALL)


func process_fall_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += air_acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		animated_sprite.flip_h = direction_x < 0.0

	if Input.is_action_just_pressed("jump"):
		if not coyote_timer.is_stopped():
			_transition_to_state(PlayerState.JUMP)
		elif jump_count < MAX_JUMPS:
			_transition_to_state(PlayerState.DOUBLE_JUMP)

	if is_on_floor():
		_transition_to_state(PlayerState.GROUND)


func _transition_to_state(new_state: PlayerState) -> void:
	var previous_state := current_state
	current_state = new_state

	match previous_state:
		PlayerState.FALL:
			coyote_timer.stop()

	match current_state:
		PlayerState.GROUND:
			jump_count = 0
			if previous_state == PlayerState.FALL:
				play_tween_touch_ground()

		PlayerState.JUMP:
			velocity.y = jump_speed
			current_gravity = jump_gravity
			velocity.x = direction_x * jump_horizontal_speed
			animated_sprite.play("Jump")
			jump_count = 1
			play_tween_jump()
			dust.emitting = true

		PlayerState.DOUBLE_JUMP:
			velocity.y = double_jump_speed
			current_gravity = double_jump_gravity
			velocity.x = direction_x * jump_horizontal_speed
			animated_sprite.play("Jump")
			jump_count = MAX_JUMPS
			play_tween_jump()
			dust.emitting = true

		PlayerState.FALL:
			animated_sprite.play("Fall")
			if jump_count == MAX_JUMPS:
				current_gravity = double_jump_fall_gravity
			else:
				current_gravity = fall_gravity

			if previous_state == PlayerState.GROUND:
				coyote_timer.start()


func play_tween_touch_ground() -> void:
	var tween := create_tween()
	tween.tween_property(animated_sprite, "scale", Vector2(1.1, 0.9), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2(0.9, 1.1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.15)


func play_tween_jump() -> void:
	var tween := create_tween()
	tween.tween_property(animated_sprite, "scale", Vector2(1.15, 0.86), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2(0.86, 1.15), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.15)
