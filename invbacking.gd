extends Button


var prevc:int = 0


func _process(_delta:float) -> void:
	var c = get_child_count()
	if c == prevc:
		return
	prevc = c
	if c > 0:
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_filter = MOUSE_FILTER_STOP
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_filter = MOUSE_FILTER_PASS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var c = get_child_count()
		if c > 0:
			get_child(c - 1).queue_free()
			get_viewport().set_input_as_handled()
