extends TextureProgressBar

func _ready() -> void:
	# Get the enemy node directly above this bar
	var enemy = get_parent()
	
	if enemy:
		# Set the bar values using the enemy's health variables
		self.max_value = enemy.max_health
		self.value = enemy.current_health
		
		# Connect to the enemy's custom signal
		enemy.health_changed.connect(_on_enemy_health_changed)

func _on_enemy_health_changed(new_health: int) -> void:
	# Update the bar when the enemy takes damage
	self.value = new_health
