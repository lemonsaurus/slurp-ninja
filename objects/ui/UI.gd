extends CanvasLayer


func _on_death(body):
	if body == $"../Player":
		$DeathText.visible = true
