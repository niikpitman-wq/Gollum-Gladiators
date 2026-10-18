extends Area2D

@onready var cooldown: Timer = $bounce_pad_cooldown
@onready var sprite_pad: AnimatedSprite2D = $sprite_pad

var pad_ready: bool = true

func _on_body_entered(body: Node2D) -> void:
	if pad_ready and body.name == 'player':
		pad_ready = false
		if not pad_ready:
			print(' this is working and something else it the root of it all')
			sprite_pad.play("not_ready_pad")
		cooldown.start()
		body.bounce()
		if pad_ready:
			sprite_pad.play("ready_pad")
		if sprite_pad.animation == 'ready_pad':
			print(' it is still not working')

func _on_bounce_pad_cooldown_timeout() -> void:
	pad_ready = true 
	if pad_ready:
		sprite_pad.play("ready_pad")
	else:
		sprite_pad.play("not_ready_pad")
	print(' somthing is wrong here')
