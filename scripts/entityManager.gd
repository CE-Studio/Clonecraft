extends Node3D
class_name EntityManager


static var instance:EntityManager


func _ready() -> void:
	instance = self


static func _reset() -> void:
	instance = null
