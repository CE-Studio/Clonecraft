extends MeshInstance3D

var life:float = 1


func _process(delta: float) -> void:
    life -= delta
    if life < 0:
        queue_free()
