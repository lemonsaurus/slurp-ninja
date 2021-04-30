"""
This script controls the player character.
"""
extends KinematicBody2D

const GRAVITY = 20
const MAX_SPEED = 1000
const FRICTION_AIR = 0.95
const FRICTION_GROUND = 0.85
const TONGUE_PULL = 25

var velocity = Vector2(0,0)
var tongue_velocity = Vector2(0,0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			$Tongue.slurp(event.position - get_viewport().size * 0.5)
			$Sprite.frame = 1

		else:
			$Tongue.release()
			$Sprite.frame = 0


func _physics_process(_delta: float) -> void:

	velocity.y += GRAVITY

	if $Tongue.hooked:
		var tongue_direction = to_local($Tongue.tip_location).normalized() 
		tongue_velocity = tongue_direction * TONGUE_PULL
		
		if tongue_velocity.y > 0:
			tongue_velocity.y *= 0.55
		
		else:
			tongue_velocity.y *= 1.65
			
	else:
		tongue_velocity = Vector2(0,0)
	velocity += tongue_velocity

	# This is the magic sauce. This makes it actually move.
	move_and_slide(velocity, Vector2.UP)
	
	# Apply some clamps. We don't want the frog moving _too_ fast.
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	# Apply surface friction
	var grounded = is_on_floor()
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		if velocity.y >= 5:		        # Keep the y-velocity small such that
			velocity.y = 5		        # gravity doesn't make this number huge
			
	elif is_on_ceiling() and velocity.y <= -5:
		velocity.y = -5

	# Apply air friction
	if !grounded:
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR
