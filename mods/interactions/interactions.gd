extends Mod


const MODID:StringName = "interactions"


var placing := false
var breaking := false
var _oldplace := false
var _placestart := Vector3i.ZERO
var _highlight:MeshInstance3D


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


func _process(_delta:float) -> void:
	if !WorldControl.isPaused():
		if placing and (player.lookingAt != null):
			var targpos:Vector3i
			if Input.is_action_pressed("game_sneak"):
				targpos = player.lookingAt.position
			else:
				targpos = player.lookingAt.previous_position
			_highlight.position = ((_placestart + targpos) / 2.0) + Vector3(0.5, 0.5, 0.5)
			_highlight.scale = (_placestart - targpos).abs() + Vector3i.ONE


func _ununhandled_input(event:InputEvent) -> void:
	if !WorldControl.isPaused():
		if event.is_action_pressed("game_place"):
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				var ii := i.getItem()
				if ii.hasInteractionOverride:
					if ii.interactionOverride.call():
						return
				if ii.isTool:
					# TODO implement tools
					return
				if ii.isVoxel:
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
		
		if placing:
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
