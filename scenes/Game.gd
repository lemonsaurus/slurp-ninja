extends Node2D

export var play_music = true


func _ready():
	if self.play_music:
		Frogjutsu.play_if_stopped()
