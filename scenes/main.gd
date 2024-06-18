extends Node2D

signal add_item(item: ItemData, count: int)
var potato = preload("res://assets/potato.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	emit_signal("add_item", potato, 1)
