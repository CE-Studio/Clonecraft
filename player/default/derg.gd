extends EntityModel


@onready var bodyGround:Node3D = $bodyGround
@onready var head:Node3D = $head
@onready var larm:Node3D = $bodyGround/bodyCenter/larm
@onready var rarm:Node3D = $bodyGround/bodyCenter/rarm
@onready var lleg:Node3D = $bodyGround/bodyCenter/lleg
@onready var rleg:Node3D = $bodyGround/bodyCenter/rleg
@onready var tail:Node3D = $bodyGround/bodyCenter/tail
@onready var tail2:Node3D = $bodyGround/bodyCenter/tail/tail2
@onready var tail3:Node3D = $bodyGround/bodyCenter/tail/tail2/tail3
@onready var tail4:Node3D = $bodyGround/bodyCenter/tail/tail2/tail3/tail4


func animate(delta:float) -> void:
	bodyGround.rotation_degrees.y = look.y - bodyRotation
	head.rotation_degrees.x = look.x
	head.rotation_degrees.y = look.y
	larm.rotation.x = sin(time) / 20
	larm.rotation.z = -(sin(time * 1.13765) + 1) / 40
	rarm.rotation.x = -sin(time) / 20
	rarm.rotation.z = (sin(time * 1.13765) + 1) / 40
	larm.rotation.x += sin(moveDistance * 1.5) * (speed * 0.8)
	rarm.rotation.x -= sin(moveDistance * 1.5) * (speed * 0.8)
	lleg.rotation_degrees.x = 12.5
	rleg.rotation_degrees.x = 12.5
	lleg.rotation.x -= sin(moveDistance * 1.5) * (speed * 0.8)
	rleg.rotation.x += sin(moveDistance * 1.5) * (speed * 0.8)
	tail.rotation_degrees.x = -30 - (speed * 20)
	tail.rotation.z = sin(moveDistance * 1.5) * (speed * 0.1)
	tail2.rotation.z = sin(moveDistance * 1.5) * (speed * 0.1)
	tail3.rotation.z = sin((moveDistance * 1.5) - 0.5) * (speed * 0.1)
	tail4.rotation.z = sin((moveDistance * 1.5) - 1) * (speed * 0.1)
	tail.rotation.z += deg_to_rad(-bodyRotation * 0.5) * speed
	tail2.rotation.z += deg_to_rad(-bodyRotation * 0.5) * speed
	tail3.rotation.z += deg_to_rad(-bodyRotation * 0.5) * speed
	tail4.rotation.z += deg_to_rad(-bodyRotation * 0.5) * speed
	tail.rotation.z += sin(time * 1.024987) / 20
	tail2.rotation.z += sin(time * 1.024987) / 20
	tail3.rotation.z += sin((time * 1.024987) - 0.5) / 20
	tail4.rotation.z += sin((time * 1.024987) - 1) / 20
