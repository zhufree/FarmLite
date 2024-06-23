extends Node2D
const TIME_GRADIENT = preload("res://assets/time_gradient.tres")
const LAND = preload("res://scenes/land.tscn")
signal add_item(item: ItemData, count: int)
signal all_ready
var resources = {}
var grab_slot = null
var land_datas:Array[LandData] = []

@onready var canvas_layer = $CanvasLayer
@onready var time_label = %TimeLabel
@onready var canvas_modulate = %CanvasModulate
@onready var point_light_2d = %PointLight2D
@onready var inventory = $CanvasLayer/Inventory
@onready var lands = %Lands

# Called when the node enters the scene tree for the first time.
func _ready():
	load_resources_from_folder("res://assets/crops_resource/")
	load_resources_from_folder("res://assets/tools_resource/")
	_init_lands()#初始化土地
	all_ready.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if grab_slot:
		grab_slot.position = get_global_mouse_position() - Vector2(8, 8)
	#更新时钟
	_refresh_clock()

func _on_button_pressed():
	# add a random item
	emit_signal("add_item", resources['potato'], 1)
	emit_signal("add_item", resources['radish'], 2)
	emit_signal("add_item", resources['onion'], 3)
	emit_signal("add_item", resources['hoe'], 3)
	emit_signal("add_item", resources['sickle'], 2)

func load_resources_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var extension = file_name.get_extension()
			if extension == "tres":
				var file_path = folder_path + "/" + file_name
				var resource = ResourceLoader.load(file_path)
				if resource:
					# 使用文件名作为键，将资源存储在字典中
					resources[file_name.get_slice('.', 0)] = resource
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")

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
	else:#TODO:如果没有存档，初期应该怎么处理由做工具的人决定吧，此处写的是按放在场景里的两块土地
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
	SaveManager.save_data.save_inventory(inventory.inventory)
	land_datas = []
	for land in lands.get_children():
		land.save()
		land_datas.append(land.land_data)
	SaveManager.save_data.save_lands(land_datas)
	SaveManager.save()
