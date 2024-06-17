extends Control


@onready var grid_container = $GridContainer
var inventory = []
var item_scene = preload("res://scenes/inventory/item.tscn")

func _ready():
	var new_item = item_scene.instantiate()
	var potato = load("res://assets/potato.tres")
	new_item.item = potato
	call_deferred("_add_item_to_grid", new_item)

func _add_item_to_grid(new_item):
	grid_container.add_child(new_item)

func update_items():
	pass
		
# 示例：添加物品
func add_item():
	pass

# 示例：移除物品
func remove_item():
	pass

