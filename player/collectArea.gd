extends CollisionShape3D


func _process(delta: float) -> void:
	if scale == Vector3.ONE:
		scale = Vector3(0.001, 0.001, 0.001)
	else:
		scale = Vector3.ONE
