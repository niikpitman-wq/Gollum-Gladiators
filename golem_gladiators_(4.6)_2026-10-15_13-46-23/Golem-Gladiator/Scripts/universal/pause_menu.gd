extends Control

@export var initial_scene: StringName = &""

func _ready() -> void:
	# Plays the "reset" animation when the node enters the scene tree
	$AnimationPlayer.play("reset")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume()


func _process(delta: float) -> void:
	test_esc()


func test_esc() -> void:
	# Checks for the "esc" input map action
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		_pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		_resume()


func _pause() -> void:
	get_tree().paused = true
	$AnimationPlayer.play("blur")


func _resume() -> void:
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")


func _on_resume_pressed() -> void:
	_resume()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	_resume()
	SceneLoader.load_scene(initial_scene)
