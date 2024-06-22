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
const MAX_EXP = 86400#土的干涸时间是游戏时间1天

var crop_node:CropNode = null
var current_state = LandState.WEED
var exp_point:int = 0
var last_record_exp:int#TODO:和加载存档有关
var planted:bool = false

@onready var texture_rect = $TextureRect

func _ready():
	GlobalTime.recalculate.connect(_recalculate)
	
func change_state(new_state):
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
	#TODO:这里还没有判断手里拿的工具，今后可以用if 持有物 is 类: 来处理
	match current_state:
		LandState.WEED:
			change_state(LandState.BARREN)
		LandState.BARREN:
			change_state(LandState.PLOWED)
		LandState.PLOWED:
			change_state(LandState.DRY)
		LandState.DRY:
			#TODO:按初期的设想好像是干土地也可以种种子，这里还没有做切换工具的功能，之后需要改一下逻辑
			#如果需要种植就调用_plant(crop_data:Crop)就好，把持有物传进去
			change_state(LandState.WATERED)#这里目前只浇水，为了测试方便
		LandState.WATERED:
			if crop_node:
				exp_point = 0#如果种植了就重新浇水
			else:
				_plant(load("res://assets/crops_resource/spinach.tres"))
				#TODO:没种植就种植一个菠菜先，这里应该根据选的种子不同种植不同的作物

func _dry():
	change_state(LandState.DRY)
	exp_point = 0

func _plant(crop_data:Crop):
	#调用这个种植作物
	crop_node = CROP.instantiate()
	crop_node.crop = crop_data
	add_child(crop_node)
	
func _recalculate(period):
	exp_point = last_record_exp + period
	var exp_overflow = exp_point - MAX_EXP
	if exp_overflow >= 0:
		_dry()
		if crop_node:#如果种植了
			crop_node.recalculate(period-exp_overflow,exp_overflow)#运进去2倍经验的时间和1倍经验的时间
	else:
		exp_overflow = 0#初始化一下，不做也行
		
