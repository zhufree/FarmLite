extends Control

@onready var grid_container = $MarginContainer2/GridContainer
@onready var slots_container = $MarginContainer/GridContainer


var slot_nodes = []
signal item_grabbed(item: SlotData)
signal item_exchanged()
var slot_scene = preload("res://scenes/inventory/slot.tscn")
var grabbed_slot = null

func _ready():
	InventoryManager.update_inventory_UI.connect(update_item_UI)
	update_item_UI()

func update_item_UI():
	for child in grid_container.get_children():
		child.queue_free()
		slot_nodes = []
	for slot in InventoryManager.inventory:
		var new_slot_node = slot_scene.instantiate()
		new_slot_node.slotData = slot
		new_slot_node.click_item.connect(on_item_clicked)
		new_slot_node.add_to_group('Slot')
		slot_nodes.append(new_slot_node)
		grid_container.add_child(new_slot_node)

func on_item_clicked(slot: SlotData):
	if grabbed_slot == null and slot.item:
		# grab item
		# create an empty slot at orignal index
		var emptySlotData = SlotData.new()
		emptySlotData.index = slot.index
		InventoryManager.inventory[slot.index] = emptySlotData
		grabbed_slot = slot
		update_item_UI()
		item_grabbed.emit(slot)
	elif grabbed_slot != null:
		# exchange item
		var target_index = slot.index
		slot.index = grabbed_slot.index
		InventoryManager.inventory[grabbed_slot.index] = slot
		grabbed_slot.index = target_index
		InventoryManager.inventory[target_index] = grabbed_slot.duplicate()
		grabbed_slot = null
		update_item_UI()
		item_exchanged.emit()

func show_storage() -> void:
	#var storage_slots:Array[Node] = get_tree().get_nodes_in_group("StorageSlots")
	for slot in slots_container.get_children().slice(0,12):
		slot.show()
	for slot in grid_container.get_children().slice(0,12):
		slot.show()
	size.y = 94
	position.y = 117

func hide_storage() -> void:
	#var storage_slots:Array[Node] = get_tree().get_nodes_in_group("StorageSlots")
	for slot in slots_container.get_children().slice(0,12):
		slot.hide()
	for slot in grid_container.get_children().slice(0,12):
		slot.hide()
	size.y = 28
	position.y = 183
	
func get_action_slot_info(action:StringName) -> SlotData:
	var choose_slot_data =  {
		"tool_q": InventoryManager.inventory[12],
		"tool_w": InventoryManager.inventory[13],
		"tool_e": InventoryManager.inventory[14],
		"tool_r": InventoryManager.inventory[15],
	}[action]
	if Global.current_holding_item == choose_slot_data:
		Global.current_holding_item = null
		Input.set_custom_mouse_cursor(null)
	else:
		Global.current_holding_item = choose_slot_data
		var atlas_texture = choose_slot_data.item.icon
		set_cursor_icon(atlas_texture)
	var choose_slot_node = {
		"tool_q": slot_nodes[12],
		"tool_w": slot_nodes[13],
		"tool_e": slot_nodes[14],
		"tool_r": slot_nodes[15],
	}[action]
	for node in slot_nodes:
		node.on_unchoose()
	choose_slot_node.on_choose()
	return choose_slot_data

func set_cursor_icon(atlas_texture: AtlasTexture):
	var source_texture = atlas_texture.atlas
	var region = atlas_texture.region
	# 创建一个新的 Image 并从 AtlasTexture 中提取数据
	var image = Image.new()
	image = image.create(region.size.x, region.size.y, false, Image.FORMAT_RGBA8)

	# 从源纹理中提取相应的区域
	var buffer_image = source_texture.get_image()
	image.blit_rect(buffer_image, Rect2(region.position, region.size), Vector2.ZERO)

	# 调整 Image 大小
	var new_width = region.size.x * 2  # 放大两倍
	var new_height = region.size.y * 2  # 放大两倍
	image.resize(new_width, new_height)

	# 创建一个新的 ImageTexture
	var cursor_texture = ImageTexture.new()
	cursor_texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(cursor_texture)
