extends Label


var _time := 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
    _time += delta
    if _time >= 10:
        modulate.a = 1 - (_time - 10)
    if _time >= 11:
        queue_free()
