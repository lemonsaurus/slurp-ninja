extends Button


func _retry():
	get_tree().change_scene("res://main.tscn")


func _on_pressed():
	_retry()
