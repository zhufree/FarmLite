extends Control

@onready var grid_container = $MarginContainer2/GridContainer

@export var inventory: Array[SlotData] = []
var slot_scene = preload("res://scenes/inventory/slot.tscn")

func _ready():
	pass

func update_item_UI():
	for child in grid_container.get_children():
		child.queue_free()
	for slot in inventory:
		var new_slot = slot_scene.instantiate()
		new_slot.item = slot
		grid_container.add_child(new_slot)

func add_item(item: ItemData, count = 1):
	var item_exist = false
	for slot in inventory:
		if slot.slotItem.name == item.name:
			item_exist = true
			slot.count += 1
			break
	if not item_exist:
		var new_slot_item = SlotData.new()
		new_slot_item.slotItem = item
		new_slot_item.count = 1
		inventory.append(new_slot_item)
	update_item_UI()
# 示例：移除物品
func remove_item():
	pass


func _on_add_item(item, count):
	add_item(item, count)
