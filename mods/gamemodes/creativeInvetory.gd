extends PanelContainer


var gui_item:PackedScene = preload("res://gui/GuiItem.tscn")
@onready var grid:GridContainer = $scrollContainer/hBoxContainer/gridContainer
var ignore_items:Array[StringName] = [&"clonecraft:air", &"clonecraft:tileEntity"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup.call_deferred()
	redraw.call_deferred()


func setup() -> void:
	var p = get_parent().get_parent()
	if p is InventoryTabs:
		var i = get_parent().get_index()
		p.set_tab_icon(i, preload("res://gui/infinvico.png"))
		p.set_tab_title(i, "")
		p.set_tab_tooltip(i, Translator.translate(&"gameplay.inventory.creative"))


func pick(i:GUIItem) -> void:
	if not InventoryLayer.holding:
		InventoryLayer.hold(i.item, null)
	else:
		InventoryLayer.drop_into(null)


func redraw() -> void:
	for i in grid.get_children():
		i.queue_free()
	for i in ItemManager.items.keys():
		if not (i in ignore_items):
			var ngi:GUIItem = gui_item.instantiate()
			ngi.clicked.connect(pick)
			grid.add_child(ngi)
			ngi.assign(ItemManager.ItemStack.new(i, 1))


func _on_button_pressed() -> void:
	InventoryLayer.drop_into(null)
