extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_right = 0
	offset_bottom = 0
	offset_top = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
