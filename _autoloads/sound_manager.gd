extends Node

@onready var sfx_pool_1: AudioStreamPlayer = $SFXPool_1
@onready var sfx_pool_2: AudioStreamPlayer = $SFXPool_2
@onready var sfx_pool_3: AudioStreamPlayer = $SFXPool_3
@onready var sfx_pool_4: AudioStreamPlayer = $SFXPool_4
@onready var sfx_pool_5: AudioStreamPlayer = $SFXPool_5
@onready var sfx_pool: Array[AudioStreamPlayer] = [$SFXPool_1, $SFXPool_2, $SFXPool_3, $SFXPool_4, $SFXPool_5]
@onready var music_player: AudioStreamPlayer = $MusicPlayer

func play_sfx(stream: AudioStream, pitch_randomness: float) -> void:
	var sfx_player: AudioStreamPlayer = sfx_pool.pick_random()
	sfx_player.stream = stream
	sfx_player.pitch_scale = 1.0 + pitch_randomness * (randf() - 0.5)
	sfx_player.play()

func play_music(stream: AudioStream) -> void:
	music_player.stream = stream
	music_player.play()
