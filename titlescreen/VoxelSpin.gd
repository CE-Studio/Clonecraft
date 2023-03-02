extends Node3D


func _process(delta):
    rotation.y -= (delta / 30)
