class_name LevelManager extends Node2D

@export var levels: Array[PackedScene] = [preload("res://scenes/Level_1.tscn"), preload("res://scenes/Level_2.tscn"), preload("res://scenes/Level_3.tscn"), preload("res://scenes/Level_5.tscn")]

var current_level: Level
var level_count: int = 0

func _ready() -> void:
	current_level = levels[0].instantiate()
	add_child(current_level)
	current_level.level_completed.connect(func() -> void:
		next_level()
	)

func next_level() -> void:
	current_level.queue_free()
	level_count += 1
	if level_count < levels.size():
		current_level = levels[level_count].instantiate()
		current_level.level_completed.connect(func() -> void:
			next_level()
		)
		add_child(current_level)
	else:
		GameManager.set_game_state(GameManager.GameState.GAME_OVER)
