extends Node3D


func _process(delta) -> void:
	rotation.y -= (delta / 30)
