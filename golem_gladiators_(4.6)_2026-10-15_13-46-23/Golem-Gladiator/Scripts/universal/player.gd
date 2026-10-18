extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $player_sprites

signal health_changed(new_health: int)

var health = 100
var min_health = 0
var max_health = 100
@onready var curent_health: int = max_health

const BASE_SPEED = 450
const JUMP_VELOCITY = -600
const RISE_GRAVITY_MULTIPLIER = 1.5
const FALL_GRAVITY_MULTIPLIER = 3.0
const wall_fall = 150
const PUSHBACK = 1000
const air_control = 4

# wall stuff
var wall_contact_coyote: float = 0.0
const wall_contact_coyote_timer: float = 0.2
var wall_jump_lock: float = 0.0
const wall_jump_lock_timer: float = 0.15 

var look_dir_x: int = 1
var blink_mode: bool = true
var WallJumpReady: bool = false
var current_speed = BASE_SPEED
var isAttacking: bool = false
var isSlaming: bool = false
var isDashingAttack: bool = false
var isDashing = false
var last_direction = 1.0
var jump_count = 0
var start_position = Vector2(0,0)
var isReady: bool = true
var isWallSliding: bool = false
var left_dir: bool = false
var right_dir: bool = false

# --- NEW/UPDATED INVINCIBILITY VARIABLES ---
var spawn: bool = true
var is_post_hurt_invincible: bool = false # Tracks if player is in post-hit i-frames


var attack_duration_timer: float = 0.0
const MAX_ATTACK_DURATION: float = 0.35 


# Helper function to easily check if player shouldn't take damage right now
func is_invincible() -> bool:
	return spawn or is_post_hurt_invincible


func _physics_process(delta: float) -> void:
	# Continuous UI checks
	if curent_health <= 20:
		$AnimationPlayer.play("low_health")
	else:
		$AnimationPlayer.play("RESET")
		
	# --- UPDATED BLINK EFFECT FOR BOTH SPAWN AND POST-HURT I-FRAMES ---
	if is_invincible():
		if spawn:
			curent_health = max_health
			health_changed.emit(curent_health)
		
		# Slow down the blink to every 4 physics frames
		if Engine.get_physics_frames() % 4 == 0: 
			animation.visible = !animation.visible
	else:
		animation.visible = true

	# Handle input lockout timing for Wall Jumps
	if wall_jump_lock > 0:
		wall_jump_lock -= delta

	# Add gravity (disabled during dash)
	if not is_on_floor() and not isDashing:
		if velocity.y > 0:
			velocity += get_gravity() * FALL_GRAVITY_MULTIPLIER * delta
		else:
			velocity += get_gravity() * RISE_GRAVITY_MULTIPLIER * delta
	elif is_on_floor_only():
		jump_count = 0

	# Wall detection - Only run if not currently in hitstun
	if $HurtTimer.is_stopped():
		if not is_on_floor() and velocity.y > 0 and is_on_wall_only():
			look_dir_x = sign(get_wall_normal().x) * -1 
			wall_contact_coyote = wall_contact_coyote_timer
			isWallSliding = true
		else:
			isWallSliding = false
			wall_contact_coyote -= delta

		if isWallSliding:
			velocity.y = wall_fall
			velocity.x = 0 
			WallJumpReady = true
		else:
			WallJumpReady = false
	else:
		isWallSliding = false
		WallJumpReady = false

	# Handle jump
	if Input.is_action_just_pressed("jump") and not isAttacking and not isDashing and $HurtTimer.is_stopped():
		if WallJumpReady:
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * PUSHBACK
			wall_jump_lock = wall_jump_lock_timer 
		elif jump_count < 2:
			jump_count += 1
			velocity.y = JUMP_VELOCITY
			if jump_count == 2:
				animation.play("d_jump")

	# Handle attack input
	if Input.is_action_just_pressed("attack") and not isAttacking and not isDashing and $HurtTimer.is_stopped():
		isAttacking = true
		$Area_Attack/Attack_Shape.disabled = false
		attack_duration_timer = MAX_ATTACK_DURATION 
	
		if is_on_floor():
			animation.play("attack")
			if right_dir:
				velocity.x = 20
		elif left_dir:
			velocity.x = -20
		else:
			animation.play("falling_attack")
			
	# Turning Attacking off states & overrides
	if isAttacking and animation.animation == "attack":
		var total_frames = animation.sprite_frames.get_frame_count("attack")
		if animation.frame >= total_frames - 1:
			$Area_Attack/Attack_Shape.disabled = true
			isAttacking = false
			
	if isAttacking and animation.animation == "falling_attack":
		if is_on_floor():
			animation.play('slam')
		if velocity.y < -500:
			var total_frames = animation.sprite_frames.get_frame_count("falling_attack")
			if animation.frame >= total_frames - 1:
				$Area_Attack/Attack_Shape.disabled = true
				isAttacking = false
				
	if isAttacking and animation.animation == 'slam':
		var total_frames = animation.sprite_frames.get_frame_count("slam")
		velocity.x = 0
		if animation.frame >= total_frames - 1:
			$Area_Attack/Attack_Shape.disabled = true
			isAttacking = false
			
	if isAttacking and animation.animation == 'dash_attack':
		var total_frames = animation.sprite_frames.get_frame_count("dash_attack")
		if animation.frame >= total_frames - 1:
			$Area_Attack/Attack_Shape.disabled = true
			isAttacking = false

	# Get input direction
	var direction := Input.get_axis("left", "right")
	
	if direction != 0 and $HurtTimer.is_stopped():
		last_direction = sign(direction)

	# Handle Dash input
	if Input.is_action_just_pressed("dash") and not isDashing and not isAttacking and isReady and $HurtTimer.is_stopped():
		isReady = false
		isDashing = true
		$dashtimer.start()
		$CoolDownTimer.start()
		current_speed = BASE_SPEED * 2.5
		animation.play("dash")

	# Movement logic
	if isDashing:
		velocity.x = last_direction * current_speed
		velocity.y = 0
	elif not isAttacking:
		if $HurtTimer.is_stopped():
			if wall_jump_lock <= 0:
				if direction:
					if is_on_floor_only():
						velocity.x = direction * current_speed
					else:
						velocity.x = move_toward(velocity.x, direction * current_speed, current_speed * delta * air_control)
					animation.flip_h = direction < 0
					$Area_Attack.scale.x = -0.5 if direction < 0 else 0.5
				else:
					if is_on_floor():
						velocity.x = move_toward(velocity.x, 0, current_speed)
					else:
						velocity.x = move_toward(velocity.x, 0, current_speed * delta * 2)
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, current_speed * delta * 8)
			else:
				velocity.x = move_toward(velocity.x, 0, current_speed * delta * 2)

	if last_direction > 0:
		left_dir = false
		right_dir = true
	else:
		left_dir = true
		right_dir = false

	if Input.is_action_just_pressed("KYS"):
		take_damage(20)

	move_and_slide()

	if position.y > 900:
		respawn()

	# Animations updates
	if not isAttacking and not isDashing and $HurtTimer.is_stopped():
		if is_on_floor():
			if abs(velocity.x) > 0.1:
				animation.play("run")
			else:
				animation.play("idle")
		else:
			if animation.animation != "d_jump":
				animation.play("jump")
			elif not animation.is_playing():
				animation.play("jump")


#Damage
func take_damage(amount: int) -> void:
	# If player is spawn-protected or recently hit, completely ignore damage
	if is_invincible():
		return 
		
	curent_health = clampi(curent_health - amount, min_health, max_health)
	
	if curent_health > 0:
		isAttacking = false
		isDashing = false
		$Area_Attack/Attack_Shape.disabled = true
		
		# Lock out inputs for 0.3 seconds
		$HurtTimer.start(0.3)
		animation.play("hurt")
		
		# Trigger post-hit invincibility
		is_post_hurt_invincible = true
		$IFrameTimer.start(1.0) # Player is safe for 1.0 second total
		
		# Apply knockback push
		velocity.x = -last_direction * (BASE_SPEED * 0.8)
		velocity.y = -350.0 
	else:
		respawn()
		
	health_changed.emit(curent_health)


func floor_spike() -> void:
	velocity.y = -PUSHBACK + 400

func bounce():
	velocity.y = -PUSHBACK

func respawn() -> void:
	position = start_position
	velocity = Vector2.ZERO
	jump_count = 0
	isAttacking = false
	isDashing = false
	$Area_Attack/Attack_Shape.disabled = true
	curent_health = max_health
	health_changed.emit(curent_health)
	$HurtTimer.stop()
	
	# Clear out I-Frame status on death/respawn
	is_post_hurt_invincible = false
	$IFrameTimer.stop()

#dashing
func _on_dashtimer_timeout() -> void:
	current_speed = BASE_SPEED
	isDashing = false

#dashing cool down
func _on_cool_down_timer_timeout() -> void:
	isReady = true

#spawn protection and also allowing some bugs to get rid of
func _on_spawn_timer_timeout() -> void:
	spawn = false
	print('no longer just spawn')

#invicibillity
func _on_i_frame_timer_timeout() -> void:
	is_post_hurt_invincible = false
	print('Invincibility worn off')

func _on_area_attack_body_entered(body: Node2D) -> void:
	if body != self and body.has_method("take_damage"):
		body.take_damage(25) 
		print("Hit enemy! Dealt damage.")

#i hate every part of this. i wished that i started using states from the begginging i tried to change it not that long ago but, i had too complecated script for me to transfer it.
