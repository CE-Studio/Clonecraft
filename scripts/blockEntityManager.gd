extends Node3D
class_name BlockEntityManager


@onready var terrain:VoxelTerrain = $"../VoxelTerrain"


func _on_voxel_terrain_mesh_block_exited(position: Vector3i) -> void:
	pass
