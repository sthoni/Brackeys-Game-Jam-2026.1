class_name GameUI extends CanvasLayer

@onready var health_bar: ProgressBar = %ProgressBar

func _ready() -> void:
	health_bar.value = 3.0
	SignalBus.connect("player_stats_changed", func(health: int, stamina: float) -> void:
		health_bar.value = health
	)
