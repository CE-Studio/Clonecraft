extends GridContainer


var guii:PackedScene = preload("res://gui/GuiItem.tscn")
var guib:PackedScene = preload("res://gui/GuiItemBlank.tscn")


func _ready() -> void:
	redraw()
	WorldControl.instance._p.inventory.content_changed.connect(redraw)


func slotClick(id:int) -> void:
	if InventoryLayer.holding:
		if InventoryLayer.heldSourceInventory != WorldControl.instance._p.inventory:
			if not InventoryLayer.dropInto(WorldControl.instance._p.inventory):
				return
		WorldControl.instance._p.hotbarItems[id] = WorldControl.instance._p.inventory.get_item_from_stack(InventoryLayer.heldItem)
		InventoryLayer.holding = false
	else:
		WorldControl.instance._p.hotbarItems[id] = null
	redraw()
	Hotbar.instance.redraw()


func redraw() -> void:
	for i in get_children():
		i.queue_free()
	var id = 0
	for i in WorldControl.instance._p.hotbarItems:
		var gi
		if i == null:
			gi = guib.instantiate()
		else:
			gi = guii.instantiate()
			gi.assign(i)
		gi.slotID = id
		add_child(gi)
		gi.slotPressed.connect(slotClick)
		id += 1
