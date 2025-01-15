extends CMDprocessor.Command


func getCommandInvocation() -> String:
	return "tp"


func getCommandArgList(index:int) -> Array:
	match index:
		-1:
			return ["[String Player]", "<Int X>", "<Int Y>", "<Int Z>"]
		0:
			return WorldControl.getPlayerList()
		1:
			return [str(WorldControl.getPlayer(WorldControl.localUsername).global_position.x)]
		2:
			return [str(WorldControl.getPlayer(WorldControl.localUsername).global_position.y)]
		3:
			return [str(WorldControl.getPlayer(WorldControl.localUsername).global_position.z)]
	return []


func execute(args:Array) -> Variant:
	var l := args.size()
	var p := "__localplayer__"
	var x
	var y
	var z
	if l == 4:
		p = str(args[0])
		x = Statics.toNumber(args[1])
		y = Statics.toNumber(args[2])
		z = Statics.toNumber(args[3])
	elif l == 3:
		x = Statics.toNumber(args[0])
		y = Statics.toNumber(args[1])
		z = Statics.toNumber(args[2])
	elif l < 3:
		CMDprocessor.throw("cmd.error.missing_arg", "Expected 3-4 arguments, got " + str(l))
		return false
	elif l > 4:
		CMDprocessor.throw("cmd.error.too_many_args", "Expected 3-4 arguments, got " + str(l))
		return false
	var player := WorldControl.getPlayer(p)
	if player == null:
		CMDprocessor.throw("cmd.error.player_not_found", "Player \"" + p + "\" is not online")
		return false
	if (x == null) or (y == null) or (z == null):
		CMDprocessor.throw("cmd.error.arg_invalid", "X, Y, or Z is not a valid number")
		return false
	player.global_position = Vector3(x, y, z)
	return true
