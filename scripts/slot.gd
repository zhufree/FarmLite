extends Control

class_name Slot
@export var item: SlotData
@onready var sprite = $CenterContainer/Sprite2D
@onready var count_label = $Control/CountLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = item.slotItem.icon
	count_label.text = str(item.count)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
