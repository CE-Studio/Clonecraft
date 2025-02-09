extends Node3D
class_name ParticleManager


static var instance:ParticleManager
static var gpuEffects:Dictionary = {}


static func _reset() -> void:
	instance = null
	gpuEffects = {}


func _ready() -> void:
	instance = self
	registerGPUeffect("clonecraft:explosion", preload("res://components/explparticles.tscn"))


static func registerGPUeffect(ID:StringName, effect:PackedScene) -> bool:
	gpuEffects[ID] = effect
	return true


static func spawnGPUeffect(ID:StringName, pos:Vector3) -> GPUParticles3D:
	var effect:GPUParticles3D = gpuEffects[ID].instantiate()
	effect.finished.connect(effect.queue_free)
	instance.add_child(effect)
	effect.position = pos
	effect.emitting = true
	return effect
