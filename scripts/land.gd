extends Control
class_name Land

enum LandState {
	WEED,
	BARREN,
	PLOWED,
	DRY,
	WATERED
}
const CROP = preload("res://scenes/crop.tscn")
const MAX_EXP = 86400 #土的干涸时间是游戏时间1天

var land_data = LandData.new()
var crop_node:CropNode = null
var current_state:LandState = LandState.WEED
var exp_point:int = 0
var planted:bool = false

@onready var texture_rect = $TextureRect


func _ready():
	GlobalTime.recalculate.connect(_recalculate)

func change_state(new_state):
	exp_point = 0 #附带了一个浇水
	current_state = new_state
	update_tile()

func update_tile():
	match current_state:
		LandState.WEED:
			texture_rect.texture = load("res://assets/land-weed.png")
		LandState.BARREN:
			texture_rect.texture = load("res://assets/land-uncultivated.png")
		LandState.PLOWED:
			texture_rect.texture = load("res://assets/land-plowed.png")
		LandState.DRY:
			texture_rect.texture = load("res://assets/land-plowed.png")
		LandState.WATERED:
			texture_rect.texture = load("res://assets/land-watered.png")

func _physics_process(delta):
	_update_exp(delta)

func _update_exp(delta):
	if current_state == LandState.WATERED:
		exp_point += delta * GlobalTime.speed * GlobalTime.CYCLE_MINUTE
	if exp_point >= MAX_EXP:
		_dry()

func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_click_on_land()


func _click_on_land():
	if crop_node:
		match crop_node.current_state:
			CropNode.CropState.RIPE:
				# 收获
				change_state(LandState.WEED)
				InventoryManager.add_item(crop_node.crop, 1)
				InventoryManager.add_item(crop_node.seed, 2)
				crop_node.queue_free()
				crop_node = null
				return
	match current_state:
		LandState.WEED:
			if Global.current_holding_item.item.name == '镰刀':
				change_state(LandState.BARREN)
		LandState.BARREN:
			if Global.current_holding_item.item.name == '锄头':
				change_state(LandState.PLOWED)
		LandState.PLOWED:
			change_state(LandState.DRY)
		LandState.DRY:
			if Global.current_holding_item.item.name == '水壶':
				change_state(LandState.WATERED)#这里目前只浇水，为了测试方便
		LandState.WATERED:
			exp_point = 0 #浇水
			if !crop_node and Global.current_holding_item.item is Seed and Global.current_holding_item.count > 0:
				_plant(Global.get_crop_from_seed(Global.current_holding_item.item.name), Global.current_holding_item.item)
				Global.current_holding_item.count -= 1

func _dry():
	change_state(LandState.DRY)

func _plant(crop_data:Crop, seed_data: Seed):
	#调用这个种植作物
	land_data.crop = crop_data
	crop_node = CROP.instantiate()
	crop_node.crop = crop_data
	crop_node.seed = seed_data
	add_child(crop_node)

func _init_land():
	var index = get_parent().get_children().find(self)
	land_data = SaveManager.save_data.lands[index]
	change_state(land_data.current_state)
	if land_data.crop and land_data.seed:
		_plant(land_data.crop, land_data.seed)

func _recalculate(period):
	_init_land()
	exp_point = land_data.land_last_record_exp + period
	var exp_overflow = exp_point - MAX_EXP
	if exp_overflow >= 0:
		_dry()
	else:
		exp_overflow = 0#初始化一下，不做也行
	if crop_node:#如果种植了
		crop_node.last_record_exp = land_data.crop_last_record_exp
		crop_node.recalculate(period-exp_overflow,exp_overflow)#运进去2倍经验的时间和1倍经验的时间

func save():
	land_data.position = position
	land_data.current_state = current_state
	land_data.land_last_record_exp = exp_point
	if crop_node:
		land_data.crop_last_record_exp = crop_node.exp_point
