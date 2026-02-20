class_name DebugMenu extends CanvasLayer

@onready var DebugLabel: Label = %DebugLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("debug_message", _on_debug_message)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_debug_message(message: String) -> void:
	DebugLabel.text = message + "\n" + DebugLabel.text

func _unhandled_key_input(event: InputEvent) -> void:
	pass
