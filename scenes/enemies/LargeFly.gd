extends KinematicBody2D

signal fly_moved (new_location)

export var fly_speed = 30
onready var initial_y = self.global_position.y
onready var initial_x = self.global_position.x
onready var tongue = $"../Player/Tongue/Tip"

var velocity = Vector2(0,0)
var being_slurped = false


func _physics_process(_delta):
	"""Move the fly around, but not too much.
	
	TODO: Make this not suck.
	"""
	
	match being_slurped:
		false:
			# Set initial movement
			velocity.y = rand_range(-self.fly_speed, self.fly_speed)
			velocity.x = rand_range(-self.fly_speed, self.fly_speed)
			
			# If we're more than 10 pixels off initial position,
			# we'll start moving back towards initial.
			var y_distance = self.global_position.y - self.initial_y
			var x_distance = self.global_position.x - self.initial_x
			
			# Handle y distance	
			if abs(y_distance) > 5:
				if y_distance > 0:
					velocity.y = rand_range(-self.fly_speed, -1)
				else:
					velocity.y = rand_range(1, self.fly_speed)
					
			# Handle x distance
			if abs(x_distance) > 5:
				if x_distance > 0:
					velocity.x = rand_range(-self.fly_speed, 1)
				else:
					velocity.x = rand_range(1, self.fly_speed)

		true:
			velocity.y = rand_range(self.fly_speed * 10, 0)
			velocity.x = rand_range(-self.fly_speed, 0)

	move_and_slide(velocity, Vector2.UP)


func _on_being_slurped(body):
	"""Handle slurps."""
	if body == tongue:
		self.being_slurped = true
		$Sprite.frame = 1
		$SFX/Idle.stop()
		$SFX/Dead.play()
