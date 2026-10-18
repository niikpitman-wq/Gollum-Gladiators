extends TextureProgressBar 

func _ready() -> void:
	# Get the player node directly above this scene
	var player = get_parent()
	
	if player:
		# Set the bar values directly since the script is ON the bar
		self.max_value = player.max_health
		self.value = player.curent_health
		
		# Connect to player's custom signal
		player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int) -> void:
	# Update the bar directly
	self.value = new_health
