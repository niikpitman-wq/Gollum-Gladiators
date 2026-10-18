extends Area2D

var start = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and start:
		get_parent().get_node('SpawnTimer').start()
		start = false
