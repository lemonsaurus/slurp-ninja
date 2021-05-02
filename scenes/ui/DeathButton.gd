extends Button


func _retry():
	get_tree().change_scene("res://Game.tscn")


func _on_pressed():
	_retry()
