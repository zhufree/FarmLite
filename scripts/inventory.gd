extends Control

@onready var grid_container = $MarginContainer2/GridContainer

@export var inventory: Array[SlotData] = []
signal item_grabbed(item: SlotData)
signal item_exchanged()
var slot_scene = preload("res://scenes/inventory/slot.tscn")
var grabbed_slot = null

func _ready():
	inventory = SaveManager.save_data.inventory
	if inventory.size() == 0:
		inventory.resize(16)
		for i in inventory.size():
			var emptySlot = SlotData.new()
			emptySlot.index = i
			inventory[i] = emptySlot
	else:
		update_item_UI()

func update_item_UI():
	for child in grid_container.get_children():
		child.queue_free()
	for slot in inventory:
		var new_slot_node = slot_scene.instantiate()
		new_slot_node.slotData = slot
		new_slot_node.connect('remove_item', Callable(self, "on_item_removed"))
		new_slot_node.connect('click_item', Callable(self, "on_item_clicked"))
		new_slot_node.add_to_group('Slot')
		grid_container.add_child(new_slot_node)

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
	update_item_UI()


func remove_item():
	pass

func get_min_index():
	# 获取最小的空槽位index放物品
	var min_index = 0
	for slot in inventory:
		if slot.item and slot.index == min_index:
			min_index += 1
		elif slot.item and slot.index > min_index:
			return min_index
	return min_index


func _on_add_item(item, count):
	add_item(item, count)


func on_item_removed(item):
	var emptySlotData = SlotData.new()
	emptySlotData.index = item.index
	inventory[item.index] = emptySlotData
	update_item_UI()


func on_item_clicked(slot: SlotData):
	if grabbed_slot == null:
		# grab item
		# create an empty slot at orignal index
		var emptySlotData = SlotData.new()
		emptySlotData.index = slot.index
		inventory[slot.index] = emptySlotData
		grabbed_slot = slot
		update_item_UI()
		emit_signal("item_grabbed", slot)
	else:
		# exchange item
		var target_index = slot.index
		slot.index = grabbed_slot.index
		inventory[grabbed_slot.index] = slot
		grabbed_slot.index = target_index
		inventory[target_index] = grabbed_slot.duplicate()
		grabbed_slot = null
		update_item_UI()
		emit_signal("item_exchanged")
