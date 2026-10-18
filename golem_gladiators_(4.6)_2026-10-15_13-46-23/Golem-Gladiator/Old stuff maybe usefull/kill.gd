extends Area2D

var damage_amount = 20

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.take_damage(damage_amount)
		print('dealt damgae')
