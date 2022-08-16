class_name Mod
extends Node

var man:BlockManager
var tool:VoxelToolTerrain
var player:Player
var terrain:VoxelTerrain


func refman(ref):
	man = ref
	terrain = man.get_node("/root/Node3D/VoxelTerrain")
	player = man.get_node("/root/Node3D/player")
	tool = terrain.get_voxel_tool()


func noScript(_pos, _meta) -> void:
	pass
