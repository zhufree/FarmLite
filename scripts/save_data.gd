extends Resource
class_name SaveData

@export var last_record_system_time_unix: int
@export var last_record_global_time_unix: int
@export var inventory: Array[SlotData] = []

func save_inventory(_inventory):
	inventory = _inventory
