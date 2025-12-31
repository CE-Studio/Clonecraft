extends Object
class_name UiManager

## This class is not finished yet.


static var _gui_item_packed = preload("res://gui/GuiItem.tscn")


static var elements:Dictionary = {}


static func create_gui_item_stack(item:ItemManager.ItemStack) -> GUIItem:
	var i:GUIItem = _gui_item_packed.instantiate()
	i.assign(item)
	return i


static func register_element(element:GUIElement):
	pass
