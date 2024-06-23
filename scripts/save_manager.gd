extends Node

var save_file_path = ProjectSettings.globalize_path("res://")
var save_file_name = "farm_save.tres"
var save_data = SaveData.new()

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func load_save_data():
	if FileAccess.file_exists(save_file_path + save_file_name):
		save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
		print('save data loaded')
	
func save():
	save_data.last_record_system_time_unix = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	save_data.last_record_global_time_unix = GlobalTime.global_time_unix_float
	print(save_data.last_record_global_time_unix)
	ResourceSaver.save(save_data, save_file_path + save_file_name)
	print('data saved')
# Called when the node enters the scene tree for the first time.
func _ready():
	verify_save_directory(save_file_path)
	load_save_data()

