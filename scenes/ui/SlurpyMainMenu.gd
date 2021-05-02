extends Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.frame = randi() % self.hframes


func _process(delta):
	self.rotate(-0.02)
