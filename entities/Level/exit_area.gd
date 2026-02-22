class_name ExitArea extends Node2D

signal portal_activated

@onready var light: PointLight2D = %PointLight2D
@onready var interactable_area: InteractableArea = %InteractableArea

var is_enabled := false
var is_interactable := false

func _ready() -> void:
	interactable_area.monitoring = false
	interactable_area.interacted.connect(func() -> void:
		SoundManager.play_sfx(preload("res://assets/sfx/teleport.wav"), 1.0)
		emit_signal("portal_activated")
	)


func activate() -> void:
	interactable_area.monitoring = true
	light.enabled = true
	is_enabled = true
