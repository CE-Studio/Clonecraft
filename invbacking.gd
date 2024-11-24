extends Button
class_name InventoryLayer


static var pItem:PackedScene = preload("res://gui/GuiItem.tscn")
static var instance:InventoryLayer
static var holding := false
static var heldItem:ItemManager.ItemStack
static var heldSourceInventory:Inventory
static var gHeldItem:GUIItem


var prevc:int = 0
@onready var vp := get_viewport()


func _ready() -> void:
	instance = self


static func hold(iitem:ItemManager.ItemStack, iinv:Inventory) -> bool:
	if holding:
		return false
	holding = true
	heldItem = iitem.copy()
	heldSourceInventory = iinv
	gHeldItem = pItem.instantiate()
	gHeldItem.mouse_filter = MOUSE_FILTER_IGNORE
	gHeldItem.assign(iitem)
	instance.add_child(gHeldItem)
	return true


static func dropInto(oinv:Inventory) -> bool:
	if not holding:
		return false
	if oinv == heldSourceInventory:
		holding = false
		gHeldItem.queue_free()
		return true
	if heldSourceInventory == null:
		if oinv.addItem(heldItem.copy()):
			holding = false
			return true
		return false
	if oinv == null:
		if heldSourceInventory.extractItem(heldItem):
			holding = false
			return true
		return false
	if oinv.addItem(heldItem.copy()):
		if heldSourceInventory.extractItem(heldItem):
			holding = false
			gHeldItem.queue_free()
			return true
		else:
			if oinv.extractItem(heldItem):
				return false
			else:
				print("!!! POSSIBLE ITEM DUPLICATION DETECTED !!!")
				print(heldSourceInventory)
				print(oinv)
				return false
	return false


func _p() -> void:
	var c = get_child_count()
	if c == prevc:
		return
	prevc = c
	if c > 0:
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_filter = MOUSE_FILTER_STOP
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_filter = MOUSE_FILTER_PASS


func _process(_delta:float) -> void:
	_p()
	if holding:
		if is_instance_valid(gHeldItem):
			gHeldItem.global_position = vp.get_mouse_position() - Vector2(23, 23)
		else:
			holding = false
	else:
		if is_instance_valid(gHeldItem):
			gHeldItem.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var c = get_child_count()
		if c > 0:
			get_child(c - 1).queue_free()
			get_viewport().set_input_as_handled()


func _on_pressed() -> void:
	if holding:
		var i := heldItem.copy()
		if (heldSourceInventory == null) or (heldSourceInventory.extractItem(i)):
			WorldControl.instance._p.throwItem(i)
			holding = false
