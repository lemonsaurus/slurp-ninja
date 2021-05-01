"""
This script controls the player character.
"""
extends KinematicBody2D

export var gravity = 20
export var max_speed = 1000
export var friction_air = 0.95
export var tongue_pull = 25

var friction_ground = 0.85
var velocity = Vector2(0,0)
var tongue_velocity = Vector2(0,0)
var is_flipping = false
var is_initialized = false
var flip_speed = 2


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			$Tongue.slurp(event.position - get_viewport().size * 0.5)
			$Sprite.frame = 1
			$SFX.slurp()

		else:
			$Tongue.release()
			$Sprite.frame = 0


func _physics_process(_delta: float) -> void:

	# Gravity is a thing that exists.
	velocity.y += gravity

	# Slurp physics!
	if $Tongue.hooked:
		var tongue_direction = to_local($Tongue.tip_location).normalized() 
		tongue_velocity = tongue_direction * tongue_pull
		
		if tongue_velocity.y > 0:
			tongue_velocity.y *= 0.55
		
		else:
			tongue_velocity.y *= 1.65
			
	else:
		tongue_velocity = Vector2(0,0)
	velocity += tongue_velocity
	
	# Rotate around like a madman
	var grounded = is_on_floor()
	if not $Tongue.hooked and not grounded:
		$Sprite.rotate(-0.1 * self.flip_speed)
		
		if not self.is_flipping and self.is_initialized:
			$SFX.flip()
			self.is_flipping = true
			
	
	# Reset flip
	if $Tongue.hooked or grounded:
		self.is_flipping = false
		self.flip_speed = rand_range(0.5, 3.0)
		

	# This is the magic sauce. This makes it actually move.
	move_and_slide(velocity, Vector2.UP)
	
	# Apply some clamps. We don't want the frog moving _too_ fast.
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	# Apply surface friction
	if grounded:
		
		# Is this the first time?
		if not self.is_initialized:
			self.is_initialized = true
		
		$Sprite.rotation = 0
		velocity.x *= friction_ground	# Apply friction only on x (we are not moving on y anyway)
		if velocity.y >= 5:		        # Keep the y-velocity small such that
			velocity.y = 5		        # gravity doesn't make this number huge
			
	elif is_on_ceiling() and velocity.y <= -5:
		velocity.y = -5

	if not grounded:
		# Apply air friction		
		velocity.x *= friction_air
		if velocity.y > 0:
			velocity.y *= friction_air
			
