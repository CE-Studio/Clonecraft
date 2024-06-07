extends CMDprocessor.Command


func getCommandInvocation() -> String:
	return "hotbar"


func getCommandArgList(index:int) -> Array:
	if index == -1:
		return ["<Int Slot>", "<String ID>", "[Dict Metadata]"]
	elif index == 0:
		return range(1, 41)
	elif index == 1:
		return ItemManager.items.keys()
	return []


func exectue(args:Array) -> Variant:
	var p := WorldControl.getPlayer(WorldControl.localUsername)
	p.hotbarItems[int(args[0])] = p.inventory.getItemFromID(StringName(args[1]))
	return true
