extends CanvasLayer

var dead_format = "[center]%s[/center]"
var dead_strings = [
	"You're super dead, bro!",
	"You're stone cold dead.",
	"You're an ex-frog.",
	"Ninja no more.",
	"You've been eviscerated!",
	"You no longer exist!",
	"No more slurp for you.",
	"Only darkness follows.",
	"Deleted!",
	"Disintegrated!",
	"Disemboweled!",
	"Looks like you missed.",
	"Oops!",
	"How embarassing!",
	"Death becomes you.",
	"No slurp lives forever.",
	"Be more careful!"	
]


func _on_death(body):
	if body == $"../Player":
		$DeathText.bbcode_text = dead_format % self.dead_strings[randi() % self.dead_strings.size()]
		$DeathText.visible = true
		$DeathButton.visible = true
