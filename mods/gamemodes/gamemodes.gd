extends Mod


const MOD_ID := &"gamemodes"


var modes := {
	"creative": {
		"allowFlight":true,
		"allowBuild":true,
		"endlessInventory":true,
		"allowPickup":true,
		"immortal":true,
		"scale":{
			"uniform":1.0,
			"x":1.0,
			"y":1.0,
			"z":1.0,
			"speed":1.0,
			"jump":1.0,
			"range":1.0,
			"reach":1.0,
			"inventory":1.0,
			"health":1.0,
			"fallDamage":1.0,
		},
		"size":{
			"x":1.0,
			"y":1.0,
			"z":1.0,
			"speed":5.0,
			"jump":8.0,
			"reach":10.0,
			"inventory":2624.0,
			"health":200.0,
			"fallDamage":0.0,
		},
	},
	"survival": {
		"allowFlight":false,
		"isFlying":false,
		"allowBuild":true,
		"endlessInventory":false,
		"allowPickup":true,
		"immortal":false,
		"scale":{
			"uniform":1.0,
			"x":1.0,
			"y":1.0,
			"z":1.0,
			"speed":1.0,
			"jump":1.0,
			"range":1.0,
			"reach":1.0,
			"inventory":1.0,
			"health":1.0,
			"fallDamage":1.0,
		},
		"size":{
			"x":1.0,
			"y":1.0,
			"z":1.0,
			"speed":5.0,
			"jump":8.0,
			"reach":5.0,
			"inventory":2624.0,
			"health":1.0,
			"fallDamage":4.0,
		},
	},
	"adventure": {
		"allowFlight":false,
		"isFlying":false,
		"allowBuild":false,
		"endlessInventory":false,
		"allowPickup":false,
		"immortal":false,
		"scale":{
			"uniform":1.0,
			"x":1.0,
			"y":1.0,
			"z":1.0,
			"speed":1.0,
			"jump":1.0,
			"range":1.0,
			"reach":1.0,
			"inventory":1.0,
			"health":1.0,
			"fallDamage":1.0,
		},
		"size":{
			"x":1.0,
			"y":1.0,
			"z":1.0,
			"speed":5.0,
			"jump":8.0,
			"reach":5.0,
			"inventory":0.0,
			"health":20.0,
			"fallDamage":4.0,
		},
	},
}



class GamemodeCMD extends CMDprocessor.Command:
	
	
	var _mod:Mod
	
	
	func get_command_invocation() -> String:
		return "gamemode"
	
	
	func get_command_arg_list(index:int) -> Array:
		if index == -1:
			return ["<String Mode>", "[String Player]"]
		elif index == 0:
			return _mod.modes.get_keys()
		elif index == 1:
			return WorldControl.get_player_list()
		return []
	
	
	func execute(args:Array) -> Variant:
		var p:Player = null
		var l := args.size()
		
		if l <= 0:
			CMDprocessor.throw("cmd.error.missing_arg", "Game mode expected")
			return false
		elif l == 1:
			p = WorldControl.get_player(WorldControl.local_username)
		elif l == 2:
			p = WorldControl.get_player(str(args[1]))
		else:
			CMDprocessor.throw("cmd.error.too_many_args", "2 arguments expected, got " + str(l))
			return false
		
		if p == null:
			CMDprocessor.throw("cmd.error.player_not_found", "Player \"" + str(args[1]) + "\" is not online")
			return false
			
		if not _mod.modes.has(str(args[0])):
			CMDprocessor.throw("cmd.error.arg_invalid", "\"" + str(args[0]) + "\" is not a valid game mode")
			return false
		
		p.abilities.merge(_mod.modes[str(args[0])], true)
		
		return true
	
	
	func _init(mod:Mod):
		_mod = mod


func should_show_creative_inv() -> bool:
	return player.abilities["endlessInventory"]


func register_phase():
	CMDprocessor.register_command(GamemodeCMD.new(self))
	InventoryTabs.register_contextual_tab(preload("res://mods/gamemodes/creativeInv.tscn"), should_show_creative_inv)
