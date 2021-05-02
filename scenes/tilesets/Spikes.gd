extends Sprite


func _play_random_sfx() -> void:
	"""Play a random disgusting impale sfx."""
	var sound_effects = $SFX.get_children()
	var chosen_effect = sound_effects[randi() % sound_effects.size()]
	chosen_effect.play()

func _on_body_entered(body):
	if body.name == "Player":
		self.frame = 1
		self._play_random_sfx()
		body.impale()
		
