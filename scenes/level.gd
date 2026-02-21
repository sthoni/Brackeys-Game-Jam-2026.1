class_name Level extends Node2D

@onready var canvas_modulate: CanvasModulate = %CanvasModulate

func _ready() -> void:
	canvas_modulate.show()
	SignalBus.button_pressed.connect(func() -> void:
		SignalBus.emit_signal("portal_activated")
	)
