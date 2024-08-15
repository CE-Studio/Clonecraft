extends Object
class_name UiManager

## This class is not finished yet.


static var _gipacked = preload("res://gui/GuiItem.tscn")


static var elements:Dictionary = {}


static func createGuiItemstack(item:ItemManager.ItemStack) -> GUIItem:
	var i:GUIItem = _gipacked.instantiate()
	i.assign(item)
	return i


static func registerElement(element:GUIElement):
	pass
