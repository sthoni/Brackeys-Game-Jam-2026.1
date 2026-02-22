class_name MainMenu extends Control

@onready var start_button: Button = %StartButton

func _ready() -> void:
	start_button.pressed.connect(func() -> void:
		GameManager.change_scene(GameManager.GameScenes[GameManager.GameState.IN_GAME])
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
	)
