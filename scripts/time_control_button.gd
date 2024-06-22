extends Button
@export var speed:int = 0

func _on_pressed():
	if speed != 0:
		GlobalTime.paused = false
		GlobalTime.speed = speed
	else:
		GlobalTime.paused = true
