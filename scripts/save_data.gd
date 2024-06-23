extends Resource
class_name SaveData

@export var last_record_system_time_unix: int = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
@export var last_record_global_time_unix: int = 0
@export var inventory: Array[SlotData] = []
@export var lands:Array[LandData] = []

func save_inventory(_inventory):
	inventory = _inventory

func save_lands(_lands):
	lands = _lands
