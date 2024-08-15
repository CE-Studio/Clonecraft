extends Mod


var tlabel:Label
var bid:int : set = _bidSet
var itemDisp:GUIItem


func _bidSet(val:int) -> void:
	bid = val
	if bid < 0:
		bid += man.blockList.size()
	elif bid >= man.blockList.size():
		bid -= man.blockList.size()
	tlabel.text = man.blockList[bid].fullID
	itemDisp.assign(ItemManager.ItemStack.new(tlabel.text, 0))


func input(event) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == 4) && (event.pressed):
			self.bid -= 1
		elif (event.button_index == 5) && (event.pressed):
			self.bid += 1
		elif (event.button_index == 2) && (event.pressed):
			if player.lookingAt != null:
				man.setBlock(player.lookingAt.previous_position, man.blockList[bid].fullID, false)
		elif (event.button_index == 1) && (event.pressed):
			if player.lookingAt != null:
				man.setBlock(player.lookingAt.position, "clonecraft:air", false)
		elif (event.button_index == 3) && (event.pressed):
			if player.lookingAt != null:
				var pl := player.lookingAt.position
				self.bid = player.voxelTool.get_voxel(pl)
				man.log("debugtools", "Block " + str(bid))
	elif event is InputEventKey:
		if event.pressed:
			if event.as_text_keycode() == "Q":
				ItemManager.spawnWorldItem(ItemManager.ItemStack.new(man.blockList[bid].fullID, 1), player.position)


func registerPhase() -> void:
	man.log("debugtools", "This world is in debug mode! A lot of default features are overridden!")
	tlabel = Label.new()
	tlabel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	tlabel.position.y -= 20
	tlabel.text = man.blockList[bid].fullID
	Statics.get_node("/root/Node3D/Control").add_child(tlabel)
	man.inputRegister(input)
	player.abilities["allowFlight"] = true
	player.abilities["allowBuild"] = true
	itemDisp = preload("res://gui/GuiItem.tscn").instantiate()
	Statics.get_node("/root/Node3D/Control").add_child(itemDisp)
	itemDisp.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)
	itemDisp.position.y -= (20 + 46)
