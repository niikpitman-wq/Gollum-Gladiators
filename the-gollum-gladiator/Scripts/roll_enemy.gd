extends CharacterBody2D
@onready var animation : AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 500.0
var direction = -1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Only one raycast is needed
@export var edge_ray: RayCast2D
@export var sprite: Sprite2D # Drag your Sprite2D here to handle visuals

func _ready() -> void:
	if not edge_ray:
		edge_ray = $edge_ray # Make sure this matches your scene tree node name

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Patrol and edge checking
	if is_on_floor():
		# If the raycast stops hitting the floor, turn around
		if edge_ray and not edge_ray.is_colliding():
			direction = -direction # Inverts the direction (-1 becomes 1, 1 becomes -1)
			flip_enemy()
		if direction < 0:
			animation.flip_h = true
		elif direction > 0:
			animation.flip_h = false
	

	velocity.x = direction * SPEED
	move_and_slide()

func flip_enemy() -> void:
	# Flip the visual sprite
	if sprite:
		sprite.flip_h = (direction == 1)
	
	# Flip the position of the raycast so it looks ahead in the new direction
	if edge_ray:
		edge_ray.position.x = abs(edge_ray.position.x) * direction
