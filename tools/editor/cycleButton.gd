class_name CycleButton
extends Button


@export var min_value:int = 0
@export var max_value:int = 0
@export var value:int = 0


func _ready() -> void:
	text = str(value)
	custom_minimum_size.x = get_combined_minimum_size().y


func _pressed() -> void:
	value += 1
	if value > max_value:
		value = min_value
	text = str(value)
