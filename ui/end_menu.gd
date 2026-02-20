class_name EndMenu extends Control

@onready var restart_button: Button = %RestartButton
@onready var next_level: PackedScene = preload("res://scenes/Level.tscn")

func _ready() -> void:
	restart_button.pressed.connect(func() -> void:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.change_scene(next_level)
	)
