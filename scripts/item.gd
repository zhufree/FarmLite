extends Control

class_name Item
@export var item: Crop
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var atlas_texture = item.sprite
	atlas_texture.region = Rect2(Vector2(16, 16), Vector2(15, 15))  # 提取区域

	sprite.texture = atlas_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
