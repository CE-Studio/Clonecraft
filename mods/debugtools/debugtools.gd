extends Mod


var block_label:Label
var block_id:int : set = _block_id_set
var item_display:GUIItem


func _block_id_set(val:int) -> void:
	block_id = val
	if block_id < 0:
		block_id += man.block_list.size()
	elif block_id >= man.block_list.size():
		block_id -= man.block_list.size()
	block_label.text = man.block_list[block_id].full_id
	item_display.assign(ItemManager.ItemStack.new(block_label.text, 0))


func input(event) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == 4) && (event.pressed):
			self.block_id -= 1
		elif (event.button_index == 5) && (event.pressed):
			self.block_id += 1
		elif (event.button_index == 2) && (event.pressed):
			if player.looking_at != null:
				man.set_block(player.looking_at.previous_position, man.block_list[block_id].full_id, false)
		elif (event.button_index == 1) && (event.pressed):
			if player.looking_at != null:
				man.set_block(player.looking_at.position, "clonecraft:air", false)
		elif (event.button_index == 3) && (event.pressed):
			if player.looking_at != null:
				var pl := player.looking_at.position
				self.block_id = player.voxel_tool.get_voxel(pl)
				man.log("debugtools", "Block " + str(block_id))
	elif event is InputEventKey:
		if event.pressed:
			if event.as_text_keycode() == "Q":
				ItemManager.spawn_world_item(ItemManager.ItemStack.new(man.block_list[block_id].full_id, 1), player.position)


func register_phase() -> void:
	man.log("debugtools", "This world is in debug mode! A lot of default features are overridden!")
	block_label = Label.new()
	block_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	block_label.position.y -= 20
	block_label.text = man.block_list[block_id].full_id
	Statics.get_node("/root/Node3D/Control").add_child(block_label)
	man.register_input(input)
	player.abilities["allowFlight"] = true
	player.abilities["allowBuild"] = true
	item_display = preload("res://gui/GuiItem.tscn").instantiate()
	Statics.get_node("/root/Node3D/Control").add_child(item_display)
	item_display.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)
	item_display.position.y -= (20 + 46)
