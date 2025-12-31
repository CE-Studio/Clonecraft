extends VoxelStreamScript
class_name VoxelStreamWithSignals


signal aboutToSave(pos:Vector3)
@export var file_stream := VoxelStreamRegionFiles.new()


func _save_voxel_block(buffer:VoxelBuffer, pos:Vector3i, lod:int):
	aboutToSave.emit(pos)
	file_stream.save_voxel_block(buffer, pos, lod)


func _load_voxel_block(out_buffer: VoxelBuffer, position_in_blocks: Vector3i, lod: int) -> ResultCode:
	return file_stream.load_voxel_block(out_buffer, position_in_blocks, lod)


func _get_used_channels_mask() -> int:
	return file_stream.get_used_channels_mask()
