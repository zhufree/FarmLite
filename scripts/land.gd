extends Control

enum LandState {
	WEED,
	BARREN,
	PLOWED,
	DRY,
	WATERED
}

var current_state = LandState.WEED
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
