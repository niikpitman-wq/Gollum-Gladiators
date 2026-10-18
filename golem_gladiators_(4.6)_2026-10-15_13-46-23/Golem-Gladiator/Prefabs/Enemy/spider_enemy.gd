extends CharacterBody2D
@onready var animation : AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100
var direction = -1
var damage_amount = 40

#health system with iframes
@export var max_health: int = 50
var current_health: int = max_health
signal health_changed(new_health: int)

var is_invincible: bool = false
var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.25 # Time in seconds before they can be hit again

#movment
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.2 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var edge_ray: RayCast2D
@export var sprite: Sprite2D 

func _ready() -> void:
	if not edge_ray:
		edge_ray = $edge_ray 

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Process invincibility timer
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false

	# Stun/Knockback handler
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)
	else:
		if is_on_floor():
			if edge_ray and not edge_ray.is_colliding():
				direction = -direction
				flip_enemy()
			if direction < 0:
				animation.flip_h = true
			elif direction > 0:
				animation.flip_h = false
		
		velocity.x = direction * SPEED

	move_and_slide()

func flip_enemy() -> void:
	if sprite:
		sprite.flip_h = (direction == 1)
	if edge_ray:
		edge_ray.position.x = abs(edge_ray.position.x) * direction

func take_damage(amount: int, player_direction: float = 0.0) -> void:
	# Ignore the hit if the enemy was already damaged a split-second ago
	if is_invincible:
		return
		
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION

	current_health -= amount
	print("Enemy hit! Damage received: ", amount, " | Remaining health: ", current_health)
	
	health_changed.emit(current_health)
	
	# Apply Knockback Force
	knockback_timer = KNOCKBACK_DURATION
	velocity.y = -200 
	
	if player_direction != 0:
		velocity.x = player_direction * 600 
	else:
		velocity.x = -direction * 400 
	
	if current_health <= 0:
		queue_free()

func _on_kill_body_entered(body: Node2D) -> void:
	# Make sure the enemy doesn't hurt the player if the enemy is already dying/dead
	if current_health <= 0:
		return
		
	if body.name == "player":
		body.take_damage(damage_amount)
		print('dealt damgae')
		body.velocity.y = -850
		if direction == -1:
			body.velocity.x = 1500
			print('ouch right')
		elif direction == 1:
			body.velocity.x = -1500
			print('ouch left')
