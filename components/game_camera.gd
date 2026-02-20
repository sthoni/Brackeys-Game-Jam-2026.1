class_name GameCamera extends Camera2D

@export_group("Shake Settings")
@export var decay_rate: float = 4.0
@export var max_offset: Vector2 = Vector2(10.0, 10.0)
@export var max_roll: float = 0.05

var trauma: float = 0.0
var trauma_power: int = 2

func _ready() -> void:
	make_current()
	SignalBus.camera_shake_requested.connect(add_trauma)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay_rate * delta, 0.0)

		shake()
	elif offset != Vector2.ZERO or rotation != 0:
		offset = Vector2.ZERO
		rotation = 0

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount: float = pow(trauma, trauma_power)

	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

	rotation = max_roll * amount * randf_range(-1, 1)
