extends CMDprocessor.Command


func get_command_invocation() -> String:
	return "tp"


func get_command_arg_list(index:int) -> Array:
	match index:
		-1:
			return ["[String Player]", "<Int X>", "<Int Y>", "<Int Z>"]
		0:
			return WorldControl.get_player_list()
		1:
			return [str(WorldControl.get_player(WorldControl.local_username).global_position.x)]
		2:
			return [str(WorldControl.get_player(WorldControl.local_username).global_position.y)]
		3:
			return [str(WorldControl.get_player(WorldControl.local_username).global_position.z)]
	return []


func execute(args:Array) -> Variant:
	var l := args.size()
	var p := "__localplayer__"
	var x
	var y
	var z
	if l == 4:
		p = str(args[0])
		x = Statics.to_number(args[1])
		y = Statics.to_number(args[2])
		z = Statics.to_number(args[3])
	elif l == 3:
		x = Statics.to_number(args[0])
		y = Statics.to_number(args[1])
		z = Statics.to_number(args[2])
	elif l < 3:
		CMDprocessor.throw("cmd.error.missing_arg", "Expected 3-4 arguments, got " + str(l))
		return false
	elif l > 4:
		CMDprocessor.throw("cmd.error.too_many_args", "Expected 3-4 arguments, got " + str(l))
		return false
	var player := WorldControl.get_player(p)
	if player == null:
		CMDprocessor.throw("cmd.error.player_not_found", "Player \"" + p + "\" is not online")
		return false
	if (x == null) or (y == null) or (z == null):
		CMDprocessor.throw("cmd.error.arg_invalid", "X, Y, or Z is not a valid number")
		return false
	player.global_position = Vector3(x, y, z)
	return true
