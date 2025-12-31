extends Mod


const MOD_ID:StringName = "interactions"


var placing := false
var breaking := false
var _old_place := false
var _place_start := Vector3i.ZERO
var _break_pos:Vector3i
var _break_progress:float = 0
var break_power:float = 0
var _highlight:MeshInstance3D
var _break:MeshInstance3D


func update_place() -> void:
	if _old_place != placing:
		_old_place = placing
		_highlight.visible = placing
		if !placing:
			var max_count:int = 1024
			var inf:bool = player.abilities["endlessInventory"]
			if !inf:
				max_count = mini(max_count, player.get_selected_item().count)
			var item_stack:ItemManager.ItemStack = player.get_selected_item()
			var item:ItemManager.Item = item_stack.get_item()
			var at:Vector3i
			if player.looking_at != null:
				if Input.is_action_pressed("game_sneak"):
					at = player.looking_at.position
				else:
					at = player.looking_at.previous_position
			else:
				if Input.is_action_pressed("game_sneak"):
					return
				else:
					at = player.get_reach_point().floor()
			var placed:int = 0
			for x in Statics.iRange(_place_start.x, at.x):
				if placed >= max_count:
					break
				for y in Statics.iRange(_place_start.y, at.y):
					if placed >= max_count:
						break
					for z in Statics.iRange(_place_start.z, at.z):
						if placed >= max_count:
							break
						if BlockManager.set_block(Vector3i(x, y, z), item.voxel):
							placed += 1
			if !inf:
				player.inventory.extract_item(ItemManager.ItemStack.new(item_stack.item_ID, placed, item_stack.metadata))


func consume_held(count:int) -> bool:
	if player.abilities.endlessInventory:
		return true
	var item_stack:ItemManager.ItemStack = player.get_selected_item()
	item_stack = item_stack.copy()
	item_stack.count = count
	return player.inventory.extract_item(item_stack)


func _process(_delta:float) -> void:
	if !WorldControl.is_paused():
		if placing:
			if _break_progress > 0:
				_break_progress = 0
			var target_pos:Vector3i
			if  player.looking_at != null:
				if Input.is_action_pressed("game_sneak"):
					target_pos = player.looking_at.position
				else:
					target_pos = player.looking_at.previous_position
			else:
				target_pos = player.get_reach_point().floor()
			_highlight.position = ((_place_start + target_pos) / 2.0) + Vector3(0.5, 0.5, 0.5)
			_highlight.scale = Vector3((_place_start - target_pos).abs()) + Vector3(1.05, 1.05, 1.05)
		elif breaking and (player.looking_at != null):
			_break.show()
			_break.position = player.looking_at.position
			_break.position += Vector3(0.5, 0.5, 0.5)
			if _break_pos != player.looking_at.position:
				_break_pos = player.looking_at.position
				_break_progress = 0
				_break.material_override.set_shader_parameter(&"progress", 0)
			else:
				_break_progress += _delta * break_power * 2
				var s:float
				if (break_power == 1.0) and player.abilities["endlessInventory"]:
					s = 0.2
				else:
					s = man.get_block(_break_pos).break_strength
				_break.material_override.set_shader_parameter(&"progress", round(remap(_break_progress, 0, s, 0, 9)))
				if _break_progress >= s:
					man.set_block(_break_pos, &"clonecraft:air", not(player.abilities["endlessInventory"]))
					_break_progress = 0
					_break.hide()
					_break.material_override.set_shader_parameter(&"progress", 0)
		elif breaking:
			pass


func _ununhandled_input(event:InputEvent) -> void:
	if !WorldControl.is_paused():
		if event.is_action_pressed("debug_action"):
			if player.looking_at != null:
				WorldControl.explode(Vector3(player.looking_at.previous_position) + Vector3(0.5, 0.5, 0.5), 8, 100)
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
			if c is Entity:
				if c.interact(event):
					player.get_viewport().set_input_as_handled()
				return
		if event.is_action_pressed("game_place"):
			var held_item_stack := player.get_selected_item()
			if is_instance_valid(held_item_stack):
				var held_item := held_item_stack.get_item()
				if held_item.has_interaction_override:
					if held_item.interaction_override.call(event):
						if held_item.consume_on_interact > 0:
							consume_held(held_item.consume_on_interact)
						player.get_viewport().set_input_as_handled()
						return
				if held_item.is_tool:
					# TODO implement tools
					player.get_viewport().set_input_as_handled()
					return
				if held_item.is_voxel and player.abilities["allowBuild"]:
					if player.looking_at != null:
						if Input.is_action_pressed("game_sneak"):
							_place_start = player.looking_at.position
						else:
							_place_start = player.looking_at.previous_position
						placing = true
						update_place()
		elif  event.is_action_released("game_place"):
			placing = false
			update_place()
			var held_item_stack := player.get_selected_item()
			if is_instance_valid(held_item_stack):
				var held_item := held_item_stack.get_item()
				if held_item.has_interaction_override:
					if held_item.interaction_override.call(event):
						if held_item.consume_on_interact > 0:
							consume_held(held_item.consume_on_interact)
						player.get_viewport().set_input_as_handled()
						return
				if held_item.is_tool:
					player.get_viewport().set_input_as_handled()
					return
		elif event.is_action_pressed("game_break"):
			var held_item_stack := player.get_selected_item()
			if is_instance_valid(held_item_stack):
				var held_item := held_item_stack.get_item()
				if held_item.has_interaction_override:
					if held_item.interaction_override.call(event):
						if held_item.consume_on_interact > 0:
							consume_held(held_item.consume_on_interact)
						player.get_viewport().set_input_as_handled()
						return
				if held_item.is_tool:
					player.get_viewport().set_input_as_handled()
					return
			break_power = 1.0
			breaking = true
		elif event.is_action_released("game_break"):
			breaking = false
			_break.hide()
			var held_item_stack := player.get_selected_item()
			if is_instance_valid(held_item_stack):
				var held_item := held_item_stack.get_item()
				if held_item.has_interaction_override:
					if held_item.interaction_override.call(event):
						if held_item.consume_on_interact > 0:
							consume_held(held_item.consume_on_interact)
						player.get_viewport().set_input_as_handled()
						return
				if held_item.is_tool:
					player.get_viewport().set_input_as_handled()
					return
		elif event.is_action_pressed("game_throw"):
			var i := player.get_selected_item()
			if is_instance_valid(i):
				i = i.copy()
				if not Input.is_action_pressed("game_sprint"):
					i.count = 1
				if player.inventory.extract_item(i):
					player.throw_item(i)
		
		if placing or breaking:
			if (
				event.is_action_pressed("game_hotbar_layer_next") or
				event.is_action_pressed("game_hotbar_layer_prev") or
				event.is_action_pressed("game_hotbar_next") or
				event.is_action_pressed("game_hotbar_prev")
			):
				player.get_viewport().set_input_as_handled()


func register_phase() -> void:
	man.add_update(_process)
	man.register_unhandled_input(_ununhandled_input)
	_highlight = load("res://mods/interactions/highlight.tscn").instantiate()
	_highlight.hide()
	player.get_parent().add_child.call_deferred(_highlight)
	_break = load("res://mods/interactions/break.tscn").instantiate()
	_break.hide()
	player.get_parent().add_child.call_deferred(_break)
