class_name Flashlight extends Area2D

@onready var light: PointLight2D = %PointLight2D

var battery_level := 1.0

func _process(_delta: float) -> void:
	# TODO: Batterie und flackern optimieren
	battery_level -= _delta * 0.1
	light.energy = randf_range(max(1.0 * battery_level, 0.6), 1.1)
