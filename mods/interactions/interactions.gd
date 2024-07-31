extends Mod


const MODID:StringName = "interactions"


func registerPhase() -> void:
	man.addUpdate(_process)
	man.unhandledInputRegister(_ununhandled_input)


var placing := false
var breaking := false
var _oldplace := false
var _placestart := Vector3i.ZERO


func updatePlace() -> void:
	if _oldplace != placing:
		_oldplace = placing


func _process(delta:float) -> void:
	pass


func _ununhandled_input(event:InputEvent) -> void:
	if !WorldControl.isPaused():
		if event.is_action_pressed("game_place"):
			var i := player.getSelectedItem()
			if is_instance_valid(i):
				var ii := i.getItem()
				if ii.hasInteractionOverride:
					if ii.interactionOverride.call():
						return
				if ii.isTool:
					# TODO implement tools
					return
				if ii.isVoxel:
					if player.lookingAt != null:
						if Input.is_action_pressed("game_sneak"):
							_placestart = player.lookingAt.position
						else:
							_placestart = player.lookingAt.previous_position
						placing = true
						updatePlace()
		elif  event.is_action_released("game_place"):
			placing = false
			updatePlace()
