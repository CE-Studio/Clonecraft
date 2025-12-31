extends GridContainer


var gui_item:PackedScene = preload("res://gui/GuiItem.tscn")
var gui_item_blank:PackedScene = preload("res://gui/GuiItemBlank.tscn")


func _ready() -> void:
	redraw()
	WorldControl.instance._player.inventory.content_changed.connect(redraw)


func slotClick(id:int) -> void:
	if InventoryLayer.holding:
		if InventoryLayer.held_source_inventory != WorldControl.instance._player.inventory:
			if not InventoryLayer.drop_into(WorldControl.instance._player.inventory):
				return
		WorldControl.instance._player.hotbar_items[id] = WorldControl.instance._player.inventory.get_item_from_stack(InventoryLayer.held_item)
		InventoryLayer.holding = false
	else:
		WorldControl.instance._player.hotbar_items[id] = null
	redraw()
	Hotbar.instance.redraw()


func redraw() -> void:
	for i in get_children():
		i.queue_free()
	var id = 0
	for i in WorldControl.instance._player.hotbar_items:
		var gi
		if i == null:
			gi = gui_item_blank.instantiate()
		else:
			gi = gui_item.instantiate()
			gi.assign(i)
		gi.slotID = id
		add_child(gi)
		gi.slotPressed.connect(slotClick)
		id += 1
