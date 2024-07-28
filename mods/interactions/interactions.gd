extends Mod


const MODID:StringName = "interactions"


func registerPhase() -> void:
	man.unhandledInputRegister(_ununhandled_input)


func _ununhandled_input(event:InputEvent) -> void:
	pass
