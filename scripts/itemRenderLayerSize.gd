extends SubViewport


@onready var vp = get_parent().get_viewport()
@onready var cam:Camera3D = $Camera3D


func _process(_delta) -> void:
	size = vp.get_visible_rect().size
	cam.size = (size.y)
	ItemManager.screenSize = size
