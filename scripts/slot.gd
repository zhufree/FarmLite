extends Control

class_name Slot
@export var item: SlotData
@onready var sprite_btn = $TextureButton
@onready var count_label = $Control/CountLabel
@onready var desc_label = $DescContainer/MarginContainer/DescLabel
@onready var desc_container = $DescContainer
@onready var operation_container = $OperationContainer

signal remove_item(item: SlotData)
signal grab_item(item: SlotData)

var is_grab = false
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	if item:
		sprite_btn.texture_normal = item.slotItem.icon
		count_label.text = str(item.count)
		desc_label.text = item.slotItem.description


func _on_mouse_entered():
	if not is_grab and item:
		desc_container.show()


func _on_mouse_exited():
	if not is_grab and item:
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
		_on_grab_item()

func _on_drop_button_pressed():
	if item.count > 1:
		item.count -= 1
		count_label.text = str(item.count)
		operation_container.hide()
	else:
		emit_signal('remove_item', item)

func _on_grab_item():
	emit_signal('grab_item', item)
