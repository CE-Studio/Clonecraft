extends Button
class_name InventoryLayer


static var gui_item:PackedScene = preload("res://gui/GuiItem.tscn")
static var instance:InventoryLayer
static var holding := false
static var held_item:ItemManager.ItemStack
static var held_source_inventory:Inventory
static var gui_held_item:GUIItem


signal inventory_closed


var prev_count:int = 0
@onready var viewport := get_viewport()


func _ready() -> void:
	instance = self


static func hold(input_item:ItemManager.ItemStack, input_inv:Inventory) -> bool:
	if holding:
		return false
	holding = true
	held_item = input_item.copy()
	held_source_inventory = input_inv
	gui_held_item = gui_item.instantiate()
	gui_held_item.mouse_filter = MOUSE_FILTER_IGNORE
	gui_held_item.assign(input_item)
	instance.add_child(gui_held_item)
	return true


static func drop_into(output_inv:Inventory) -> bool:
	if not holding:
		return false
	if output_inv == held_source_inventory:
		holding = false
		gui_held_item.queue_free()
		return true
	if held_source_inventory == null:
		if output_inv.add_item(held_item.copy()):
			holding = false
			return true
		return false
	if output_inv == null:
		if held_source_inventory.extract_item(held_item):
			holding = false
			return true
		return false
	if output_inv.add_item(held_item.copy()):
		if held_source_inventory.extract_item(held_item):
			holding = false
			gui_held_item.queue_free()
			return true
		else:
			if output_inv.extract_item(held_item):
				return false
			else:
				BlockManager.glog("ItemManager", "!!! POSSIBLE ITEM DUPLICATION DETECTED !!!")
				BlockManager.glog("ItemManager", str(held_source_inventory))
				BlockManager.glog("ItemManager", str(output_inv))
				return false
	var temp_item := held_item.copy()
	var c := temp_item.count
	if output_inv.add_item_partial(temp_item):
		temp_item.count = c - temp_item.count
		if held_source_inventory.extract_item(temp_item):
			holding = false
			gui_held_item.queue_free()
			return true
		else:
			if output_inv.extract_item(temp_item):
				return false
			else:
				BlockManager.glog("ItemManager", "!!! POSSIBLE ITEM DUPLICATION DETECTED !!!")
				BlockManager.glog("ItemManager", str(held_source_inventory))
				BlockManager.glog("ItemManager", str(output_inv))
				return false
	return false


func _p() -> void:
	var c = get_child_count()
	if c == prev_count:
		return
	prev_count = c
	if c > 0:
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_filter = MOUSE_FILTER_STOP
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_filter = MOUSE_FILTER_PASS
		inventory_closed.emit()


func _process(_delta:float) -> void:
	_p()
	if holding:
		if is_instance_valid(gui_held_item):
			gui_held_item.global_position = viewport.get_mouse_position() - Vector2(23, 23)
		else:
			holding = false
	else:
		if is_instance_valid(gui_held_item):
			gui_held_item.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var c = get_child_count()
		if c > 0:
			get_child(c - 1).queue_free()
			get_viewport().set_input_as_handled()


func _on_pressed() -> void:
	if holding:
		var i := held_item.copy()
		if (held_source_inventory == null) or (held_source_inventory.extract_item(i)):
			WorldControl.instance._player.throw_item(i)
			holding = false
