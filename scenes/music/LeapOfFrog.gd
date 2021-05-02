extends AudioStreamPlayer


func play_if_stopped():
	"""Play this song if it's not already playing."""

	if not self.playing:
		Frogjutsu.stop()
		self.play()


