extends CharacterBody2D


const SPEED = 100.0
var direction = -1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Using @export lets you assign these directly in the inspector if paths break
@export var left_ray: RayCast2D
@export var right_ray: RayCast2D

func _ready() -> void:
	# Fallback: if you didn't manually assign them in the inspector, try to find them by path
	if not left_ray:
		left_ray = $leftray
	if not right_ray:
		right_ray = $rightray

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		# Turn around if a raycast stops colliding with the platform
		if direction == -1 and left_ray and not left_ray.is_colliding():
			direction = 1
		elif direction == 1 and right_ray and not right_ray.is_colliding():
			direction = -1

	velocity.x = direction * SPEED
	move_and_slide()
