class_name Hurtbox extends Area2D

@export var health_component: HealthComponent

func take_damage(amount: int) -> void:
	if health_component:
		health_component.current_health -= amount
