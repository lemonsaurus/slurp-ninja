"""
This script controls the player character.
"""
extends KinematicBody2D

signal player_death

export var gravity = 20
export var max_speed = 1000
export var friction_air = 0.95
export var tongue_pull = 25
export var flight_speed = 10

var friction_ground = 0.85
var velocity = Vector2(0,0)
var tongue_velocity = Vector2(0,0)
var tongue_position_right = Vector2(4, -13)
var tongue_position_left = Vector2(-13, -4)
var is_flipping = false
var is_initialized = false
var is_facing_left = false
var flip_speed = 2
var initial_position = self.global_position
var dead = false
var dead_by_fly = false


func _input(event: InputEvent) -> void:
	if not self.dead and not self.dead_by_fly and event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			var click_position = event.position - (get_viewport().get_size_override() * 0.5)
			print(click_position)
			$Tongue.slurp(click_position)
			$AnimatedSprite.animation = "Slurp"
			$AnimatedSprite.speed_scale = 7.5
			$AnimatedSprite.play()
			$SFX.slurp()

			# Flip the sprite if we're clicking behind the frog.
			if click_position.x < 0:
				$AnimatedSprite.flip_h = true
				self.is_facing_left = true
				$Tongue.position = tongue_position_left
			else:
				$AnimatedSprite.flip_h = false
				self.is_facing_left = false
				$Tongue.position = tongue_position_right

		else:
			$Tongue.release()
			$AnimatedSprite.animation = "Idle"
			$AnimatedSprite.speed_scale = 1.5
			$AnimatedSprite.play()

func _process(_delta: float) -> void:
	"""Update the UI every frame."""
	
	if not self.dead:
		# Update the distance label
		var pixels_per_meter = 100
		var offset = 4
		var distance = int(self.global_position.distance_to(self.initial_position) / pixels_per_meter) - offset
		var format_string = "[right]{distance} m[/right]"
		$"../UI/Distance".bbcode_text = format_string.format({"distance": distance})


func _physics_process(_delta: float) -> void:

	# Dead frogs don't physic.
	if self.dead:
		return

	# Gravity is a thing that exists.
	velocity.y += gravity
	
	# TODO: Rotate to face slurp target
	if $Tongue.slurping or $Tongue.hooked:
		pass
		

	# Slurp physics!
	if $Tongue.hooked:
		var tongue_distance = $Tongue.tip_location.distance_to(self.global_position)
		var tongue_direction = to_local($Tongue.tip_location).normalized()

		# Set initial velocity.
		tongue_velocity = tongue_direction * tongue_pull

		# Increase the x velocity to make the player arc.
		#
		# This will increase more and more the closer you are
		# to the tip of the tongue.
		var true_flight = 300.0 / tongue_distance
		if tongue_velocity.x > 0:
			tongue_velocity.x += self.flight_speed * true_flight
		elif tongue_velocity.x < 0:
			tongue_velocity.x -= self.flight_speed * true_flight

		# If we're falling, we want to pull up a bit faster.
		if tongue_velocity.y > 0 and tongue_distance < 250:
			tongue_velocity.y *= 0.55
		if tongue_velocity.y > 0:
			tongue_velocity.y *= 0.85
		elif tongue_velocity.y < 0:
			tongue_velocity.y *= 1.30

	else:
		tongue_velocity = Vector2(0,0)

	# This is the magic sauce. This makes it actually move.
	velocity += tongue_velocity
	velocity = move_and_slide(velocity, Vector2.UP)

	# Apply some clamps. We don't want the frog moving _too_ fast.
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

	# Make the frog flip!
	var grounded = is_on_floor()
	if not $Tongue.hooked and not grounded:

		if self.is_facing_left:
			$AnimatedSprite.rotate(0.1 * self.flip_speed)
		else:
			$AnimatedSprite.rotate(-0.1 * self.flip_speed)

		if not self.is_flipping and self.is_initialized:
			$SFX.flip()
			self.is_flipping = true
			$AnimatedSprite.animation = "Flip"
			$AnimatedSprite.stop()
			$AnimatedSprite.frame = randi() % 4

	# TODO: Write a state machine, holy shit.
	# Meanwhile, let's reset to idle if we're done flying.
	if grounded and $AnimatedSprite.animation == "Flip":
		$AnimatedSprite.animation = "Idle"
		$AnimatedSprite.speed_scale = 1.5
		$AnimatedSprite.play()

	# Reset flip states.
	if $Tongue.hooked or grounded:
		self.is_flipping = false
		self.flip_speed = rand_range(1.5, 3.0)


	# Apply surface friction
	if grounded:
		$AnimatedSprite.rotation = 0
		velocity.x *= friction_ground
		if velocity.y >= 5:
			velocity.y = 5

		# Is this the first time we land?
		if not self.is_initialized:
			self.is_initialized = true
			
		# Survive by fly!
		self.dead_by_fly = false

	# Bounce off ceilings.
	elif is_on_ceiling() and velocity.y <= -5:
		velocity.y = -5

	# Apply air friction
	if not grounded:
		velocity.x *= friction_air
		if velocity.y > 0:
			velocity.y *= friction_air


func _on_fall(body):
	if body == self and not $Tongue.hooked:
		self.dead = true
		$AnimatedSprite.visible = false
		$SFX.fall()
		$Tongue.slurping = false
		emit_signal("player_death")
		
func impale():
	self.dead = true
	$SFX.damage()
	$Tongue.release()
	$AnimatedSprite.animation = "Dead"
	emit_signal("player_death")
	
func death_by_fly():
	self.dead_by_fly = true
	$AnimatedSprite.animation = "Dead"
	$Tongue.release()
	$SFX.damage()
