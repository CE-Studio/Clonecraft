extends Node3D
class_name DebugAABB


static var instance:DebugAABB
var aabb:AABB:
	set(val):
		show()
		position = val.position
		scale = val.size
		aabb = val


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_instance_valid(instance):
		instance = self
