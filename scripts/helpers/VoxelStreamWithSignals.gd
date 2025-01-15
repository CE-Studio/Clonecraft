extends VoxelStreamScript
class_name VoxelStreamWithSignals


signal aboutToSave(pos:Vector3)
@export var rfstream := VoxelStreamRegionFiles.new()


func _save_voxel_block(buffer:VoxelBuffer, pos:Vector3i, lod:int):
	aboutToSave.emit(pos)
	rfstream.save_voxel_block(buffer, pos, lod)


func _load_voxel_block(out_buffer: VoxelBuffer, position_in_blocks: Vector3i, lod: int) -> ResultCode:
	return rfstream.load_voxel_block(out_buffer, position_in_blocks, lod)


func _get_used_channels_mask() -> int:
	return rfstream.get_used_channels_mask()
