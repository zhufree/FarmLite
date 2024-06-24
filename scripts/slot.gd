extends Control
class_name Slot

@export var slotData: SlotData

@onready var sprite_btn = $TextureButton
@onready var count_label = $Control/CountLabel
@onready var desc_label = $DescContainer/MarginContainer/DescLabel
@onready var desc_container = $DescContainer
@onready var operation_container = $OperationContainer

signal remove_item(item: SlotData)
signal click_item(item: SlotData)

var is_grab = false


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	if slotData.item:
		sprite_btn.texture_normal = slotData.item.icon
		count_label.text = str(slotData.count)
		desc_label.text = slotData.item.description

func _on_mouse_entered():
	if not is_grab and slotData.item:
		desc_container.show()

func _on_mouse_exited():
	if not is_grab and slotData.item:
		desc_container.hide()

func _on_item_pressed():
	if is_grab:
		return
	if operation_container.visible == false:
		operation_container.show()
	else:
		operation_container.hide()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_on_item_pressed()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_grab:
			get_tree().call_group("Slot", "_on_gui_input", event)
		if is_mouse_in_node():
			_on_click_item()

func _on_drop_button_pressed():
	if slotData.count > 1:
		slotData.count -= 1
		count_label.text = str(slotData.count)
		operation_container.hide()
	else:
		remove_item.emit(slotData)

func _on_click_item():
	click_item.emit(slotData)

func is_mouse_in_node() -> bool:
	var mouse_pos = get_global_mouse_position()
	var rect = Rect2(global_position, size)
	return rect.has_point(mouse_pos)
