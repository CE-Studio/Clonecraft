extends Node3D
class_name ParticleManager


static var instance:ParticleManager
static var gpu_effects:Dictionary[StringName, PackedScene] = {}


static func _reset() -> void:
	instance = null
	gpu_effects = {}


func _ready() -> void:
	instance = self
	register_gpu_effect("clonecraft:explosion", preload("res://components/explparticles.tscn"))


static func register_gpu_effect(ID:StringName, effect:PackedScene) -> bool:
	gpu_effects[ID] = effect
	return true


static func spawn_gpu_effect(ID:StringName, pos:Vector3) -> GPUParticles3D:
	var effect:GPUParticles3D = gpu_effects[ID].instantiate()
	effect.finished.connect(effect.queue_free)
	instance.add_child(effect)
	effect.position = pos
	effect.emitting = true
	return effect
