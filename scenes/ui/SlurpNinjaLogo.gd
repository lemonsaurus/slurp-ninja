extends Sprite

export var animation_speed = 10

export var max_size = 1.05
export var min_size = 0.95

var animation_rate = animation_speed / 10000.0
var increasing = true


func _process(delta):
	print(animation_rate)
	if self.increasing:
		self.scale.x += animation_rate
		self.scale.y += animation_rate
	else:
		self.scale.x -= animation_rate
		self.scale.y -= animation_rate
		
	# Invert at a certain size.
	if self.scale > Vector2(max_size, max_size):
		self.increasing = false
	elif self.scale < Vector2(min_size, min_size):
		self.increasing = true
		
		
		
