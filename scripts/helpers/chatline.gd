extends Label


var time := 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    time += delta
    if time >= 10:
        modulate.a = 1 - (time - 10)
    if time >= 11:
        queue_free()
