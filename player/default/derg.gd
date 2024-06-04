extends EntityModel


@onready var bodyGround:Node3D = $bodyGround
@onready var head:Node3D = $head


func animate(delta:float) -> void:
	bodyGround.rotation_degrees.y = look.y - bodyRotation
	head.rotation_degrees.x = look.x
	head.rotation_degrees.y = look.y
