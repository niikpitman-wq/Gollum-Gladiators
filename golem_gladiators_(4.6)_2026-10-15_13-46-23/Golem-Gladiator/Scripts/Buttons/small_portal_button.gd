extends Area2D

@export var initial_scene: StringName = &""

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		SceneLoader.load_scene(initial_scene)
