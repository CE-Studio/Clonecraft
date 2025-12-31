extends EntityModel


@onready var bodyGround:Node3D = $bodyGround
@onready var head:Node3D = $head
@onready var left_arm:Node3D = $bodyGround/bodyCenter/larm
@onready var right_arm:Node3D = $bodyGround/bodyCenter/rarm
@onready var left_leg:Node3D = $bodyGround/bodyCenter/lleg
@onready var right_leg:Node3D = $bodyGround/bodyCenter/rleg
@onready var tail:Node3D = $bodyGround/bodyCenter/tail
@onready var tail2:Node3D = $bodyGround/bodyCenter/tail/tail2
@onready var tail3:Node3D = $bodyGround/bodyCenter/tail/tail2/tail3
@onready var tail4:Node3D = $bodyGround/bodyCenter/tail/tail2/tail3/tail4


func animate(delta:float) -> void:
	bodyGround.rotation_degrees.y = look.y - body_rotation
	head.rotation_degrees.x = look.x
	head.rotation_degrees.y = look.y
	left_arm.rotation.x = sin(time) / 20
	left_arm.rotation.z = -(sin(time * 1.13765) + 1) / 40
	right_arm.rotation.x = -sin(time) / 20
	right_arm.rotation.z = (sin(time * 1.13765) + 1) / 40
	left_arm.rotation.x += sin(move_distance * 1.5) * (speed * 0.8)
	right_arm.rotation.x -= sin(move_distance * 1.5) * (speed * 0.8)
	left_leg.rotation_degrees.x = 12.5
	right_leg.rotation_degrees.x = 12.5
	left_leg.rotation.x -= sin(move_distance * 1.5) * (speed * 0.8)
	right_leg.rotation.x += sin(move_distance * 1.5) * (speed * 0.8)
	tail.rotation_degrees.x = -30 - (speed * 20)
	tail.rotation.z = sin(move_distance * 1.5) * (speed * 0.1)
	tail2.rotation.z = sin(move_distance * 1.5) * (speed * 0.1)
	tail3.rotation.z = sin((move_distance * 1.5) - 0.5) * (speed * 0.1)
	tail4.rotation.z = sin((move_distance * 1.5) - 1) * (speed * 0.1)
	tail.rotation.z += deg_to_rad(-body_rotation * 0.5) * speed
	tail2.rotation.z += deg_to_rad(-body_rotation * 0.5) * speed
	tail3.rotation.z += deg_to_rad(-body_rotation * 0.5) * speed
	tail4.rotation.z += deg_to_rad(-body_rotation * 0.5) * speed
	tail.rotation.z += sin(time * 1.024987) / 20
	tail2.rotation.z += sin(time * 1.024987) / 20
	tail3.rotation.z += sin((time * 1.024987) - 0.5) / 20
	tail4.rotation.z += sin((time * 1.024987) - 1) / 20


func animate_action(action:StringName) -> void:
	pass
