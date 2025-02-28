@tool
extends Node3D


@export var runInEditor := false
@export var trackpoint := Vector3(-0.062, 1.5, -5)
@export_range(0, 1) var center:float = 0


@onready var head:Node3D = $body/head
@onready var neck1:Node3D = $body/head/neckrod
@onready var neck2:Node3D = $body/neckpiston


@onready var headtrack:Node3D = $headcenter/headtrack
@onready var headspring:Marker3D = $headcenter/headtrack/headspring


var lerpdir := Vector3.ZERO


func _process(delta: float) -> void:
	if runInEditor or not Engine.is_editor_hint():
		var fd = clampf(delta * 10, 0, 0.1)
		headtrack.look_at(trackpoint)
		lerpdir = lerpdir.lerp(headtrack.rotation, fd)
		headtrack.rotation = lerpdir.lerp(Vector3.ZERO, center)
		headtrack.position.x = sin(headtrack.rotation.y) / 10
		head.global_rotation = headspring.global_rotation
		head.global_position = headspring.global_position
		neck1.look_at(neck2.global_position)
		neck2.look_at(neck1.global_position)
