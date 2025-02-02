extends Mod


const MODID:StringName = "interactions"


var placing := false
var breaking := false
var _oldplace := false
var _placestart := Vector3i.ZERO
var _breakpos:Vector3i
var _breakprogress:float = 0
var breakPower:float = 0
var _highlight:MeshInstance3D
var _break:MeshInstance3D


func updatePlace() -> void:
	if _oldplace != placing:
		_oldplace = placing
		_highlight.visible = placing
		if !placing and (player.lookingAt != null):
			var maxc:int = 1024
			var inf:bool = player.abilities["endlessInventory"]
			if !inf:
				maxc = mini(maxc, player.getSelectedItem().count)
			var istack:ItemManager.ItemStack = player.getSelectedItem()
			var item:ItemManager.Item = istack.getItem()
			var at:Vector3i
			if Input.is_action_pressed("game_sneak"):
				at = player.lookingAt.position
			else:
				at = player.lookingAt.previous_position
			var placed:int = 0
			for x in Statics.iRange(_placestart.x, at.x):
				if placed >= maxc:
					break
				for y in Statics.iRange(_placestart.y, at.y):
					if placed >= maxc:
						break
					for z in Statics.iRange(_placestart.z, at.z):
						if placed >= maxc:
							break
						if BlockManager.setBlock(Vector3i(x, y, z), item.voxel):
							placed += 1
			if !inf:
				player.inventory.extractItem(ItemManager.ItemStack.new(istack.itemID, placed, istack.metadata))


func consumeHeld(count:int) -> bool:
	if player.abilities.endlessInventory:
		return true
	var istack:ItemManager.ItemStack = player.getSelectedItem()
	istack = istack.copy()
	istack.count = count
	return player.inventory.extractItem(istack)


func _process(_delta:float) -> void:
	if !WorldControl.isPaused():
		if placing and (player.lookingAt != null):
			if _breakprogress > 0:
				_breakprogress = 0
			var targpos:Vector3i
			if Input.is_action_pressed("game_sneak"):
				targpos = player.lookingAt.position
			else:
				targpos = player.lookingAt.previous_position
			_highlight.position = ((_placestart + targpos) / 2.0) + Vector3(0.5, 0.5, 0.5)
			_highlight.scale = Vector3((_placestart - targpos).abs()) + Vector3(1.05, 1.05, 1.05)
		elif breaking and (player.lookingAt != null):
			_break.show()
			_break.position = player.lookingAt.position
			_break.position += Vector3(0.5, 0.5, 0.5)
			if _breakpos != player.lookingAt.position:
				_breakpos = player.lookingAt.position
				_breakprogress = 0
				_break.material_override.set_shader_parameter(&"progress", 0)
			else:
				_breakprogress += _delta * breakPower * 2
				var s:float
				if (breakPower == 1.0) and player.abilities["endlessInventory"]:
					s = 0.2
				else:
					s = man.getBlock(_breakpos).breakStrength
				_break.material_override.set_shader_parameter(&"progress", round(remap(_breakprogress, 0, s, 0, 9)))
				if _breakprogress >= s:
					man.setBlock(_breakpos, &"clonecraft:air", not(player.abilities["endlessInventory"]))
					_breakprogress = 0
					_break.hide()
					_break.material_override.set_shader_parameter(&"progress", 0)
		elif breaking:
			pass


func _ununhandled_input(event:InputEvent) -> void:
	if !WorldControl.isPaused():
		if event.is_action_pressed("debug_action"):
			if player.lookingAt != null:
				WorldControl.explode(Vector3(player.lookingAt.previous_position) + Vector3(0.5, 0.5, 0.5), 8, 100)
		if (not placing) and (not breaking) and player.raycast.is_colliding():
			var c := player.raycast.get_collider()
			if c is WorldItem:
				if event.is_action_pressed("game_break"):
					player._on_enter_item_range(c)
					player.get_viewport().set_input_as_handled()
					return
			if c is TileEntity:
				if c.interact(event):
					player.get_viewport().set_input_as_handled()
					return
		if event.is_action_pressed("game_place"):
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				var ii := i.getItem()
				if ii.hasInteractionOverride:
					if ii.interactionOverride.call(event):
						if ii.consumeOnInteract > 0:
							consumeHeld(ii.consumeOnInteract)
						player.get_viewport().set_input_as_handled()
						return
				if ii.isTool:
					# TODO implement tools
					player.get_viewport().set_input_as_handled()
					return
				if ii.isVoxel and player.abilities["allowBuild"]:
					if player.lookingAt != null:
						if Input.is_action_pressed("game_sneak"):
							_placestart = player.lookingAt.position
						else:
							_placestart = player.lookingAt.previous_position
						placing = true
						updatePlace()
		elif  event.is_action_released("game_place"):
			placing = false
			updatePlace()
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				var ii := i.getItem()
				if ii.hasInteractionOverride:
					if ii.interactionOverride.call(event):
						if ii.consumeOnInteract > 0:
							consumeHeld(ii.consumeOnInteract)
						player.get_viewport().set_input_as_handled()
						return
				if ii.isTool:
					player.get_viewport().set_input_as_handled()
					return
		elif event.is_action_pressed("game_break"):
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				var ii := i.getItem()
				if ii.hasInteractionOverride:
					if ii.interactionOverride.call(event):
						if ii.consumeOnInteract > 0:
							consumeHeld(ii.consumeOnInteract)
						player.get_viewport().set_input_as_handled()
						return
				if ii.isTool:
					player.get_viewport().set_input_as_handled()
					return
			breakPower = 1.0
			breaking = true
		elif event.is_action_released("game_break"):
			breaking = false
			_break.hide()
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				var ii := i.getItem()
				if ii.hasInteractionOverride:
					if ii.interactionOverride.call(event):
						if ii.consumeOnInteract > 0:
							consumeHeld(ii.consumeOnInteract)
						player.get_viewport().set_input_as_handled()
						return
				if ii.isTool:
					player.get_viewport().set_input_as_handled()
					return
		elif event.is_action_pressed("game_throw"):
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				i = i.copy()
				if not Input.is_action_pressed("game_sprint"):
					i.count = 1
				if player.inventory.extractItem(i):
					player.throwItem(i)
		
		if placing or breaking:
			if (
				event.is_action_pressed("game_hotbar_layer_next") or
				event.is_action_pressed("game_hotbar_layer_prev") or
				event.is_action_pressed("game_hotbar_next") or
				event.is_action_pressed("game_hotbar_prev")
			):
				player.get_viewport().set_input_as_handled()


func registerPhase() -> void:
	man.addUpdate(_process)
	man.unhandledInputRegister(_ununhandled_input)
	_highlight = load("res://mods/interactions/highlight.tscn").instantiate()
	_highlight.hide()
	player.get_parent().add_child.call_deferred(_highlight)
	_break = load("res://mods/interactions/break.tscn").instantiate()
	_break.hide()
	player.get_parent().add_child.call_deferred(_break)
