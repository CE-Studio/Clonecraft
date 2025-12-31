@tool
extends Node3D


@export var run_in_editor := false
@export var track_point := Vector3(-0.062, 1.5, -5)
@export_range(0, 1) var center:float = 0


@onready var head:Node3D = $body/head
@onready var neck1:Node3D = $body/head/neckrod
@onready var neck2:Node3D = $body/neckpiston


@onready var head_track:Node3D = $headcenter/headtrack
@onready var head_spring:Marker3D = $headcenter/headtrack/headspring


var lerp_dir := Vector3.ZERO


func _process(delta: float) -> void:
	if run_in_editor or not Engine.is_editor_hint():
		var fd = clampf(delta * 10, 0, 0.1)
		head_track.look_at(track_point)
		lerp_dir = lerp_dir.lerp(head_track.rotation, fd)
		head_track.rotation = lerp_dir.lerp(Vector3.ZERO, center)
		head_track.position.x = sin(head_track.rotation.y) / 10
		head.global_rotation = head_spring.global_rotation
		head.global_position = head_spring.global_position
		neck1.look_at(neck2.global_position)
		neck2.look_at(neck1.global_position)
