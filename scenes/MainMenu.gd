extends Control

export var play_music = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if self.play_music:
		LeapOfFrog.play_if_stopped()

