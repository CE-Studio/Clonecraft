extends Mod


const MODID:StringName = "interactions"


func registerPhase() -> void:
	man.unhandledInputRegister(_ununhandled_input)


var placing := false
var breaking := false


func _ununhandled_input(event:InputEvent) -> void:
	var t := !WorldControl.isPaused()
	if event.is_action_pressed("game_place"):
		placing = t
	elif  event.is_action_released("game_place"):
		placing = false
