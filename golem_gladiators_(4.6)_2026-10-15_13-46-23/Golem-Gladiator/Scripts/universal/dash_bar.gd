extends TextureProgressBar

func _on_dashtimer_timeout() -> void:
	self.value = 0
	$"../dashprogresschanger".start()

func _on_dashprogresschanger_timeout() -> void:
	self.value += 11
	$"../dashprogresschanger".start()
