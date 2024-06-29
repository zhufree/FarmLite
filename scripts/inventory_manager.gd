extends Node

@export var inventory: Array[SlotData] = []
signal update_inventory_UI
func _ready():
	inventory = SaveManager.save_data.inventory
	if inventory.size() == 0:
		inventory.resize(16)
		for i in inventory.size():
			var emptySlot = SlotData.new()
			emptySlot.index = i
			inventory[i] = emptySlot


func add_item(item: ItemData, count = 1):
	var item_exist = false
	for slot in inventory:
		if slot.item and slot.item.name == item.name:
			item_exist = true
			slot.count += count
			break
	if not item_exist:
		var index = get_min_index()
		var new_slot_data = SlotData.new()
		new_slot_data.item = item
		new_slot_data.count = count
		new_slot_data.index = index
		inventory[index] = new_slot_data
	update_inventory_UI.emit()

func remove_item(slot: SlotData, count = 1):
	if slot.count > 1:
		slot.count -= 1
	else:
		slot.count = 0
		slot.item = null
	update_inventory_UI.emit()
	

func get_min_index():
	# 获取最小的空槽位index放物品
	var min_index = 0
	for slot in inventory:
		if slot.item and slot.index == min_index:
			min_index += 1
		elif slot.item and slot.index > min_index:
			return min_index
	return min_index
