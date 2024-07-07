extends Node

var crops_resource = {}
var tools_resource = {}
var seeds_resource = {}
var current_holding_item: SlotData

func _ready():
	current_holding_item = SlotData.new()
	current_holding_item.item = ItemData.new()
	load_resources_from_folder("res://assets/crops_resource/", crops_resource)
	load_resources_from_folder("res://assets/tools_resource/", tools_resource)
	load_resources_from_folder("res://assets/seeds_resource/", seeds_resource)

func get_crop_from_seed(seed_name: String) -> Resource:
	var cropname = seed_name.substr(0, seed_name.length() - 2)
	for crop in crops_resource.values():
		if crop.name == cropname:
			return crop
	return null

func load_resources_from_folder(folder_path: String, target_dict: Dictionary):
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
					target_dict[file_name.get_slice('.', 0)] = resource
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
