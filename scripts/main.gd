extends Node2D

const TIME_GRADIENT = preload("res://assets/time_gradient.tres")
const LAND = preload("res://scenes/land.tscn")


var grab_slot = null
var land_datas:Array[LandData] = []
var is_display_storage_slots := true
var current_choose_slot: SlotData

@onready var canvas_layer = $CanvasLayer
@onready var time_label = %TimeLabel
@onready var canvas_modulate = %CanvasModulate
@onready var point_light_2d = %PointLight2D
@onready var inventory = $CanvasLayer/Inventory
@onready var lands = %Lands
@onready var tips: Label = $CanvasLayer/tips

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_init_lands()#初始化土地

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if grab_slot:
		grab_slot.position = get_global_mouse_position() - Vector2(8, 8)
	#更新时钟
	_refresh_clock()
	# 切换背包
	if Input.is_action_just_pressed("switch_display_storage_slots"):
		if is_display_storage_slots:
			inventory.hide_storage()
			tips.hide()
			is_display_storage_slots = false
		else:
			inventory.show_storage()
			tips.show()
			is_display_storage_slots = true
	_current_choose_tool()

func _on_button_pressed():
	# add a random item
	for key in Global.seeds_resource:
		InventoryManager.add_item(Global.seeds_resource[key], 2)
	for key in Global.tools_resource:
		InventoryManager.add_item(Global.tools_resource[key], 1)


var slot_scene = preload("res://scenes/inventory/slot.tscn")
func _on_inventory_item_grabbed(item: SlotData):
	grab_slot = slot_scene.instantiate()
	grab_slot.z_index = 99
	grab_slot.is_grab = true
	grab_slot.slotData = item
	canvas_layer.add_child(grab_slot)

func _on_inventory_item_exchanged():
	grab_slot.queue_free()
	grab_slot = null

func _init_lands():
	if SaveManager.save_data.lands:
		for item in lands.get_children():
			item.queue_free()
			await item.tree_exited
		for land_data in SaveManager.save_data.lands:
			var land_scene = LAND.instantiate()
			land_scene.land_data = land_data
			land_scene.position = land_data.position
			lands.add_child(land_scene)
	else: #TODO:如果没有存档，初期应该怎么处理由做工具的人决定吧，此处写的是按放在场景里的两块土地
		for land in lands.get_children():
			land_datas.append(land.land_data)
			SaveManager.save_data.save_lands(land_datas)

func _refresh_clock():
	time_label.text = GlobalTime.time_to_string()
	var hour_minute:float = GlobalTime.global_time["hour"] +\
			 float(GlobalTime.global_time["minute"]) / GlobalTime.CYCLE_HOUR
	canvas_modulate.color = TIME_GRADIENT.sample(hour_minute / GlobalTime.CYCLE_DAY)
	if hour_minute < 5 or hour_minute > 19:
		point_light_2d.position = get_global_mouse_position()
		point_light_2d.show()
	else:
		point_light_2d.hide()

func _on_save_button_pressed():
	SaveManager.save_data.save_inventory(InventoryManager.inventory)
	land_datas = []
	for land in lands.get_children():
		land.save()
		land_datas.append(land.land_data)
	SaveManager.save_data.save_lands(land_datas)
	SaveManager.save()

# 检测鼠标输入，根据输入获取对应的工具信息
func _current_choose_tool() -> void:
	if Input.is_action_just_pressed("choose_tool_q"):
		current_choose_slot = inventory.get_action_slot_info("tool_q")
	elif Input.is_action_just_pressed("choose_tool_w"):
		current_choose_slot = inventory.get_action_slot_info("tool_w")
	elif Input.is_action_just_pressed("choose_tool_e"):
		current_choose_slot = inventory.get_action_slot_info("tool_e")
	elif Input.is_action_just_pressed("choose_tool_r"):
		current_choose_slot = inventory.get_action_slot_info("tool_r")
