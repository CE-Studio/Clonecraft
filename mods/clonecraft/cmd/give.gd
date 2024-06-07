extends CMDprocessor.Command


func getCommandInvocation() -> String:
	return "give"


func getCommandArgList(index:int) -> Array:
	if index == -1:
		return ["<String ID>", "[Int Count]", "[String Player]", "[Dict Metadata]"]
	elif index == 0:
		return ItemManager.items.keys()
	elif index == 1:
		return [1, 10, 100, 1000]
	elif index == 2:
		return [WorldControl.getPlayerList()]
	return []


func exectue(args:Array) -> Variant:
	var p:Player = null
	var l := args.size()
	var c := 1
	
	if l <= 0:
		CMDprocessor.throw("cmd.error.missing_arg")
		return false
	
	if not ItemManager.items.has(str(args[0])):
		CMDprocessor.throw("cmd.error.arg_invalid")
		return false
	
	if l > 1:
		if args[1] is int:
			pass
		elif (args[1] is String) and (args[1].is_valid_int()):
			pass
		else:
			CMDprocessor.throw("cmd.error.arg_invalid")
			return false
		c = int(args[1])
	
	
	if l > 2:
		p = WorldControl.getPlayer(str(args[2]))
		if p == null:
			CMDprocessor.throw("cmd.error.player_not_found")
			return false
	else:
		p = WorldControl.getPlayer(WorldControl.localUsername)
			
	# TODO implement metadata arg
			
	if l > 4:
		CMDprocessor.throw("cmd.error.too_many_args")
		return false
	
	return p.inventory.addItem(ItemManager.ItemStack.new(str(args[0]), c))
