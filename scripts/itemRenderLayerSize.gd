extends SubViewport


@onready var vp = get_parent().get_viewport()
@onready var cam:Camera3D = $Camera3D


#func _ready():
#    own_world_3d = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    size = vp.get_visible_rect().size
    cam.size = (size.y)
    ItemManager.screenSize = size
