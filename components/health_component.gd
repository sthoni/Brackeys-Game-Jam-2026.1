class_name HealthComponent extends Node

signal death
signal health_changed

var current_health: int:
	get:
		return current_health
	set(value):
		current_health = value
		emit_signal("health_changed", current_health)
		if current_health <= 0:
			emit_signal("death")

func init_health(max_health: int) -> void:
	current_health = max_health
