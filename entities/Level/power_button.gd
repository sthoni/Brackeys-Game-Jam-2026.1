class_name PowerButton extends Node2D

@onready var light: PointLight2D = %PointLight2D
@onready var interactable_area: InteractableArea = %InteractableArea
@onready var audio: AudioStreamPlayer2D = %AudioStreamPlayer2D

var is_interactable := false
var is_active := false

func _ready() -> void:
	interactable_area.interacted.connect(func() -> void:
		is_active = true
		light.enabled = false
		audio.play()
		SignalBus.emit_signal("button_pressed")
	)
