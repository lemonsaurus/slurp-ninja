extends Node


func _play_random_sfx(parent: Node) -> void:
	"""Play a random audio effect in the provided parent."""
	var sound_effects = parent.get_children()
	var chosen_effect = sound_effects[randi() % sound_effects.size()]
	chosen_effect.play()


func flip():
	_play_random_sfx($Flip)
	
	
func slurp():
	_play_random_sfx($Slurp)
	

func fall():
	_play_random_sfx($Fall)
	
	
func croak():
	_play_random_sfx($Croak)
	
	
func damage():
	_play_random_sfx($Damage)
