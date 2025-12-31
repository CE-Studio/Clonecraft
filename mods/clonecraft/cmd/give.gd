extends CMDprocessor.Command


func get_command_invocation() -> String:
	return "give"


func get_command_arg_list(index:int) -> Array:
	if index == -1:
		return ["<String ID>", "[Int Count]", "[String Player]", "[Dict Metadata]"]
	elif index == 0:
		return ItemManager.items.keys()
	elif index == 1:
		return [1, 10, 100, 1000]
	elif index == 2:
		return [WorldControl.get_player_list()]
	return []


func execute(args:Array) -> Variant:
	var p:Player = null
	var l := args.size()
	var c := 1
	
	if l <= 0:
		CMDprocessor.throw("cmd.error.missing_arg", "Item ID expected")
		return false
	
	if not ItemManager.items.has(str(args[0])):
		CMDprocessor.throw("cmd.error.arg_invalid", "Item \"" + str(args[0]) + "\" does not exist")
		return false
	
	if l > 1:
		var ct = Statics.to_number(args[1])
		if ct == null:
			CMDprocessor.throw("cmd.error.arg_invalid", "\"" + str(args[1]) + "\" is not a valid number")
			return false
		c = roundi(ct)
	
	
	if l > 2:
		p = WorldControl.get_player(str(args[2]))
		if p == null:
			CMDprocessor.throw("cmd.error.player_not_found", "Player \"" + str(args[2]) + "\" is not online")
			return false
	else:
		p = WorldControl.get_player(WorldControl.local_username)
			
	# TODO implement metadata arg
			
	if l > 4:
		CMDprocessor.throw("cmd.error.too_many_args", "Expected 1-4 arguments, got " + str(l))
		return false
	
	return p.inventory.add_item(ItemManager.ItemStack.new(str(args[0]), c))
