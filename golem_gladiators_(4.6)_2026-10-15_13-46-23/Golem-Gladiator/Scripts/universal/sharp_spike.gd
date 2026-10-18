extends Area2D

@export var damage_amount: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.take_damage(damage_amount)
		body.floor_spike()
