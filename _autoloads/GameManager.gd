extends Node

enum GameState {
	MAIN_MENU,
	IN_GAME,
	PAUSED,
	GAME_OVER
}

var GameScenes := {
	GameState.MAIN_MENU: preload("res://ui/MainMenu.tscn"),
	GameState.IN_GAME: preload("res://scenes/Level.tscn"),
	GameState.GAME_OVER: preload("res://ui/EndMenu.tscn")
}

var current_game_state: GameState

signal game_state_changed(new_state: GameState)


func _ready() -> void:
	if get_tree().current_scene == GameScenes[GameState.MAIN_MENU]:
		current_game_state = GameState.MAIN_MENU
	elif get_tree().current_scene == GameScenes[GameState.IN_GAME]:
		current_game_state = GameState.IN_GAME
	game_state_changed.emit(current_game_state)
	# SoundManager.play_music(load("res://assets/music/theme.wav"))


func _process(_delta: float) -> void:
	pass


func set_game_state(new_state: GameState) -> void:
	current_game_state = new_state
	game_state_changed.emit(new_state)


func change_scene(scene_path: PackedScene) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(get_tree().current_scene, "modulate", Color.BLACK, 1.0)
	tween.tween_callback(
		func() -> void:
			call_deferred("defer_change_scene", scene_path))


func quit_game() -> void:
	get_tree().quit()


func defer_change_scene(scene_path: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene_path)

func reload_scene() -> void:
	get_tree().reload_current_scene()
