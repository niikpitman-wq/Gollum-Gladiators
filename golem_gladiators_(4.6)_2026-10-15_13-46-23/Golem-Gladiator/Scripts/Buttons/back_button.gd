extends Button

@export var initial_scene: StringName = &""

func _on_pressed() -> void:
	SceneLoader.load_scene(initial_scene)
