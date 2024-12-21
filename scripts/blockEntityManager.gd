extends Node3D
class_name BlockEntityManager


@onready var terrain:VoxelTerrain = $"../VoxelTerrain"


func _on_voxel_terrain_mesh_block_exited(position: Vector3i) -> void:
	var aabb := AABB(position * 16, Vector3i.ONE)
	if not BlockManager._tool.is_area_editable(aabb):
		print(position)
