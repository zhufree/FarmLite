extends Node2D

signal add_item(item: ItemData, count: int)
var resources = {}
var grab_slot = null

@onready var canvas_layer = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	load_resources_from_folder("res://assets/crops_resource/")
	load_resources_from_folder("res://assets/tools_resource/")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if grab_slot:
		grab_slot.position = get_global_mouse_position() - Vector2(8, 8)


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
