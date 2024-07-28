extends CMDprocessor.Command


func getCommandInvocation() -> String:
	return "hotbar"


func getCommandArgList(index:int) -> Array:
	if index == -1:
		return ["<Int Slot (0-39)>", "<String ID>", "[Dict Metadata]"]
	elif index == 0:
		return range(0, 40)
	elif index == 1:
		return ItemManager.items.keys()
	return []


func execute(args:Array) -> Variant:
	if args.size() < 2:
		CMDprocessor.throw("cmd.error.missing_arg", "Expected 2-3 args, got " + str(args.size()))
		return false
	if args.size() > 3:
		CMDprocessor.throw("cmd.error.too_many_args", "Expected 2-3 args, got " + str(args.size()))
		return false

	var c:int
	if args[0] is int:
		c = args[0]
	elif (args[0] is String) and (args[0].is_valid_int()):
		c = int(args[0])
	elif args[0] is float:
		c = roundi(args[0])
	else:
		CMDprocessor.throw("cmd.error.arg_invalid", "\"" + str(args[0]) + "\" is not a valid number")
		return false

	if c > 39:
		CMDprocessor.throw("cmd.error.arg_above_range", "Slot number cannot be larger than 39")
		return false
	if c < 0:
		CMDprocessor.throw("cmd.error.arg_below_range", "Slot number cannot be smaller than 0")
		return false

	var p := WorldControl.getPlayer(WorldControl.localUsername)
	p.hotbarItems[c] = p.inventory.getItemFromID(StringName(args[1]))
	return true
