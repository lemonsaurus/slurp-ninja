"""
Allow the tongue to shoot out like a hookshot!
"""
extends Node2D

const SPEED = 10  # Slurping speed.

onready var slurplets = $Slurplets
onready var tip = $Tip
var direction := Vector2(0,0)
var tip_location := Vector2(0,0)

var slurping = false  # Is the tongue currently in-transit?
var hooked = false    # Is the tongue hooked onto a surface?


func slurp(slurp_direction: Vector2) -> void:
	"""Slurp the tongue in the specified direction."""
	direction = slurp_direction.normalized()  # Set the trajectory
	tip_location = self.global_position       # Reset the tip to player position
	slurping = true


func release() -> void:
	"""Release the grip of the tongue"""
	slurping = false
	hooked = false


func _process(_delta: float) -> void:
	"""Orient the tongue and the slurplets for every real frame."""
	# Hide the tongue if we're not currently using it.
	self.visible = slurping or hooked
	if not self.visible:
		return
		
	# Rotate the slurplets and the tip towards their target.
	var tip_local = to_local(tip_location)
	slurplets.rotation = self.position.angle_to_point(tip_local) - deg2rad(90)
	tip.rotation = self.position.angle_to_point(tip_local) - deg2rad(90)
	
	# Slurplets start at the tip and extend down to the player.
	slurplets.position = tip_local						
	slurplets.region_rect.size.y = tip_local.length()
	

func _physics_process(_delta: float) -> void:
	"""Update the tip position for every physics frame."""
	tip.global_position = tip_location
	
	# If we're slurping, check if there's a collision and respond to it.
	if slurping:
		var collision = tip.move_and_collide(direction * SPEED)
		if collision:
			hooked = true
			slurping = false
	
	# Now that we've moved it, we need to update the location.
	tip_location = tip.global_position
