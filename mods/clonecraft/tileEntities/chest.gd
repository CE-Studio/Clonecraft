extends TileEntity


var inventory := Inventory.new()


func getID() -> StringName:
	return &"clonecraft:chest"


func _ready() -> void:
	inventory.contentChanged.connect(markDirty)


func save() -> Dictionary:
	data["inventory"] = inventory.save()
	return data


func interact(event:InputEvent) -> bool:
	if event.is_action_pressed("game_place"):
		$animationPlayer.play("open")
		var t = preload("res://mods/clonecraft/tileEntities/chestInv.tscn").instantiate()
		t.get_child(0).inv = inventory
		InventoryTabs.registerTempTab(t)
		InventoryLayer.instance.inventoryClosed.connect(close, CONNECT_ONE_SHOT)
		WorldControl.instance.openInventory()
		return true
	return false


func close():
	$animationPlayer.play("close")


func setup(pos:Vector3i, d:Dictionary):
	d.merge(
		{
			"facing": 0,
			"inventory": {
				"container": [],
				"space": 7872,
			},
		},
		false
	)
	super(pos, d)
	if not inventory.restore(data["inventory"], false):
		BlockManager.log("clonecraft", "Chest failed to load! (" + str(pos) + ")")
	$chest/Node_7.rotation_degrees.y = 90 * data.facing
