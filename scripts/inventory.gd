extends Control

@onready var grid_container = $MarginContainer2/GridContainer

@export var inventory: Array[SlotData] = []
signal item_grabbed(item: SlotData)
var slot_scene = preload("res://scenes/inventory/slot.tscn")

func _ready():
	inventory.resize(16)
	for i in inventory.size():
		var emptySlotData = SlotData.new()
		emptySlotData.index = i
		inventory[i] = emptySlotData

func update_item_UI():
	for child in grid_container.get_children():
		child.queue_free()
	for slot in inventory:
		var new_slot = slot_scene.instantiate()
		if slot.slotItem != null:
			new_slot.item = slot
			new_slot.connect('remove_item', Callable(self, "on_item_removed"))
			new_slot.connect('grab_item', Callable(self, "on_item_grabbed"))
		grid_container.add_child(new_slot)

func add_item(item: ItemData, count = 1):
	var item_exist = false
	for slot in inventory:
		if slot.slotItem and slot.slotItem.name == item.name:
			item_exist = true
			slot.count += count
			break
	if not item_exist:
		var index = get_min_index()
		var new_slot_item = SlotData.new()
		new_slot_item.slotItem = item
		new_slot_item.count = count
		new_slot_item.index = index
		inventory[index] = new_slot_item
	update_item_UI()


func remove_item():
	pass

func get_min_index():
	# 获取最小的空槽位index放物品
	var min_index = 0
	for slot in inventory:
		if slot.slotItem and slot.index == min_index:
			min_index += 1
		elif slot.slotItem and slot.index > min_index:
			return min_index
	return min_index


func _on_add_item(item, count):
	add_item(item, count)


func on_item_removed(item):
	var emptySlotData = SlotData.new()
	emptySlotData.index = item.index
	inventory[item.index] = emptySlotData
	update_item_UI()


func on_item_grabbed(item):
	var emptySlotData = SlotData.new()
	emptySlotData.index = item.index
	inventory[item.index] = emptySlotData
	update_item_UI()
	emit_signal("item_grabbed", item)
