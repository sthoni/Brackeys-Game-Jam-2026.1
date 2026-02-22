class_name Level extends Node2D

signal level_completed

@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var exit_area: ExitArea = %ExitArea

func _ready() -> void:
	canvas_modulate.show()
	SignalBus.button_pressed.connect(func() -> void:
		exit_area.activate()
	)
	exit_area.portal_activated.connect(func() -> void:
		canvas_modulate.hide()
		emit_signal("level_completed")
	)
