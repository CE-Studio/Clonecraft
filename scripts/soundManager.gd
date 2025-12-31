extends Node3D
class_name SoundManager


static var instance:SoundManager
static var sounds:Dictionary[StringName, AudioStream] = {}


static func _reset() -> void:
	instance = null
	sounds = {}


func _ready() -> void:
	instance = self
	registerSound(&"clonecraft:explosion", preload("res://sounds/effect/explode.tres"))
	registerSound(&"clonecraft:pop", preload("res://sounds/effect/pop.tres"))


static func registerSound(ID:StringName, sound:AudioStream) -> void:
	sounds[ID] = sound


static func playSound(ID:StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = sounds[ID]
	player.finished.connect(player.queue_free)
	instance.add_child(player)
	player.play()
	return player
	
	
static func play_sound_3D(ID:StringName, pos:Vector3) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.stream = sounds[ID]
	player.finished.connect(player.queue_free)
	instance.add_child(player)
	player.position = pos
	player.play()
	return player
