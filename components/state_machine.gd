class_name StateMachine extends Node

var states: Array[State] = []
var current_state: State = null

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	if new_state:
		new_state.enter()
	current_state = new_state
