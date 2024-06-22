extends Control

enum LandState {
	WEED,
	BARREN,
	PLOWED,
	DRY,
	WATERED
}

var current_state = LandState.WEED
var exp_point:int = 0
@onready var texture_rect = $TextureRect

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
	if exp_point >= 86400:
		exp_point = 0
		current_state = LandState.DRY
		update_tile()


func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_click_on_land()#此处目前没判断工具


func _click_on_land():
	match current_state:
		LandState.WEED:
			change_state(LandState.BARREN)
		LandState.BARREN:
			change_state(LandState.PLOWED)
		LandState.PLOWED:
			change_state(LandState.DRY)
		LandState.DRY:
			change_state(LandState.WATERED)
		LandState.WATERED:
			exp_point = 0
