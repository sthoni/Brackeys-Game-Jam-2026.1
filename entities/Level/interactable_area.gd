class_name InteractableArea extends Area2D

signal interacted

@onready var label: Label = %Label

var is_interactable := false

func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Player:
			label.show()
			is_interactable = true
	)
	body_exited.connect(func(body: Node2D) -> void:
		if body is Player:
			label.hide()
			is_interactable = false
	)

func _input(event: InputEvent) -> void:
	if is_interactable and event.is_action_pressed("interact"):
		emit_signal("interacted")
