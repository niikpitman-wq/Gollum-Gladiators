
extends CharacterBody2D


@onready var animation : AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 900.0
const JUMP_VELOCITY = -980.0
var jump_count = 0
var star_position = Vector2(-3480.0,40.0)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < 2:
		jump_count += 1
		velocity.y = JUMP_VELOCITY
	
	# double jump animation
	if jump_count == 2:
		animation.play("double_jump")

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			animation.flip_h = true
		elif direction > 0:
			animation.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			animation.play("run")
		else:
			animation.play("idel")
	else:
		if animation.animation != "double_jump" or not animation.is_playing():
			animation.play("jump")

# --- ADDED DEATH FUNCTION BELOW ---
func die() -> void:
	print("Player was killed!")
	get_tree().reload_current_scene()
