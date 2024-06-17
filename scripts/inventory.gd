extends Control


@onready var grid_container = $GridContainer
@export var inventory: Array[SlotData] = []
var slot_scene = preload("res://scenes/inventory/slot.tscn")

func _ready():
	pass

func update_items():
	pass
		
# 示例：添加物品
func add_item():
	pass

# 示例：移除物品
func remove_item():
	pass

