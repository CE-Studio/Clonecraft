extends CMDprocessor.Command


func getCommandInvocation() -> String:
	return "give"


func getCommandArgList(index:int) -> Array:
	if index == -1:
		return ["<String ID>", "[Int Count]", "[String Player]"]
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
	
	return true
