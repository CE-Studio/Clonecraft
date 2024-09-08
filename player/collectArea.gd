extends CollisionShape3D


func _process(delta: float) -> void:
	if scale == Vector3.ONE:
		scale = Vector3.ZERO
	else:
		scale = Vector3.ONE
