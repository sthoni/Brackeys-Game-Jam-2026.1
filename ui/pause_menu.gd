class_name PauseMenu extends CanvasLayer

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	resume_button.pressed.connect(func() -> void:
		get_tree().paused = false
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		hide()
	)
	quit_button.pressed.connect(func() -> void:
		GameManager.quit_game()
	)

func pause_game() -> void:
	get_tree().paused = true
	GameManager.set_game_state(GameManager.GameState.PAUSED)
	show()
