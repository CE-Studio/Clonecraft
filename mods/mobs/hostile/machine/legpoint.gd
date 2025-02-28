@tool
extends Node3D


@export var runInEditor := false
@export var back := false
@export var point:Node3D
@export var kneeAngle:float

@export var lowerleg:Node3D
@export var piston:Node3D
@export var rod:Node3D
@export var foot:Node3D
@export var body:Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if runInEditor or not Engine.is_editor_hint():
		var fd = clampf(delta * 10, 0, 0.1)
		global_rotation = piston.global_rotation
		lowerleg.rotation.x = kneeAngle - rotation.x
		piston.global_rotation = global_rotation
		var r = Vector3(piston.rotation)
		if back:
			piston.look_at(point.global_position, Vector3(0, 0, 1), true)
		else:
			piston.look_at(point.global_position, Vector3(0, 0, -1))
		piston.rotation.x = lerp_angle(r.x, piston.rotation.x, fd)
		piston.rotation.y = lerp_angle(r.y, piston.rotation.y, fd)
		piston.rotation.z = lerp_angle(r.z, piston.rotation.z, fd)
		var p = Vector3(rod.position)
		rod.global_position = point.global_position
		var d = rod.position.z
		rod.position = p
		rod.position.z = lerpf(rod.position.z, d, fd)
