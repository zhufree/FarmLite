extends Control
class_name CropNode

const WET_RATE = 2
const DRY_RATE = 1
enum CropState {
	SEED,
	SPROUT,
	GROWING,
	RIPE,
}

var crop:Crop #TODO:和存档有关
var land
@onready var texture_rect = %TextureRect
@onready var light_occluder_2d = %LightOccluder2D

var current_state = CropState.SEED
var exp_point:int = 0
var last_record_exp:int #TODO:和存档有关


func _ready():
	if crop:
		calculate_state()
	land = get_parent()
	
func _physics_process(delta):
	_update_exp(delta)

func _update_exp(delta):
	if current_state != CropState.RIPE:
		if land.current_state == Land.LandState.WATERED:
			exp_point += delta * GlobalTime.speed * GlobalTime.CYCLE_MINUTE * WET_RATE
		elif land.current_state == Land.LandState.DRY:
			exp_point += delta * GlobalTime.speed * GlobalTime.CYCLE_MINUTE * DRY_RATE
		else:
			queue_free()
	calculate_state()

func recalculate(wet_time,dry_time):
	exp_point = last_record_exp + wet_time * WET_RATE + dry_time * DRY_RATE
	calculate_state()

func calculate_state():
	var interval_second = crop.interval * GlobalTime.CYCLE_DAY * GlobalTime.CYCLE_HOUR * GlobalTime.CYCLE_MINUTE
	if exp_point >= interval_second * 3:
		change_state(CropState.RIPE)
	elif exp_point >= interval_second * 2:
		change_state(CropState.GROWING)
	elif exp_point >= interval_second:
		change_state(CropState.SPROUT)
	else:
		change_state(CropState.SEED)

func change_state(new_state):
	current_state = new_state
	update_tile()

func update_tile():
	texture_rect.texture = crop.frame.get_frame_texture("default",int(current_state))
	if current_state > 0:
		light_occluder_2d.show()
	else:
		light_occluder_2d.hide()

