class_name Flashlight extends Area2D

@onready var light: PointLight2D = %PointLight2D

var battery_level := 3.0

func _process(delta: float) -> void:
	# TODO: Batterie und flackern optimieren
	battery_level -= delta * 0.1
	light.energy = randf_range(battery_level, battery_level + randf_range(0.0, 0.5))
	if battery_level <= 0.0:
		light.energy = 0.0
		monitorable = false
		monitoring = false
