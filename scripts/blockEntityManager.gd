extends Node3D
class_name BlockEntityManager


static var te_list:Dictionary[StringName, PackedScene] = {
	&"null:null": preload("res://components/InvalidTileEntity.tscn")
}
static var instance:BlockEntityManager


@onready var terrain:VoxelTerrain = $"../VoxelTerrain"


static func _reset() -> void:
	te_list = {
		&"null:null": preload("res://components/InvalidTileEntity.tscn")
	}
	instance = null


func  _ready() -> void:
	instance = self


func _save(aabb:AABB, tool:VoxelTool) -> void:
	for i in _save_chunk(aabb, tool):
		i.queue_free()


func _clear(aabb:AABB) -> void:
	for i in get_children():
		if i is TileEntity:
			if aabb.has_point(Vector3(i.pos) + Vector3(0.5, 0.5, 0.5)):
				i.queue_free()


func _save_chunk(aabb:AABB, tool:VoxelTool) -> Array[TileEntity]:
	#DebugAABB.instance.aabb = aabb
	var to_save:Array[TileEntity] = []
	for i in get_children():
		if i is TileEntity:
			if aabb.has_point(Vector3(i.pos) + Vector3(0.5, 0.5, 0.5)):
				to_save.append(i)
	for i in to_save:
		var relative_pos := Vector3i(
			posmod(i.pos.x, int(aabb.size.x)),
			posmod(i.pos.y, int(aabb.size.y)),
			posmod(i.pos.z, int(aabb.size.z)),
		)
		var metadata = tool.get_voxel_metadata(relative_pos)
		if metadata is Dictionary:
			metadata.merge({&"tileEntity": [i.get_id(), i.save()]}, true)
		else:
			metadata = {}
			metadata.merge({&"tileEntity": [i.get_id(), i.save()]}, true)
		tool.set_voxel_metadata(relative_pos, metadata)
	return to_save


func _process_load(pos:Vector3i, metadata, aabb:AABB):
	var relative_pos := aabb.position + Vector3(pos)
	var block_info := BlockManager.get_block(relative_pos)
	if block_info.full_id == &"clonecraft:tileEntity":
		if metadata is Dictionary:
			if metadata.has(&"tileEntity"):
				var te = metadata[&"tileEntity"]
				if te_list.has(te[0]):
					var tile:TileEntity = te_list[te[0]].instantiate()
					tile.position = relative_pos
					add_child(tile)
					tile.setup(Vector3i(relative_pos), te[1])


func _load(aabb:AABB, buf:VoxelBuffer) -> void:
	buf.for_each_voxel_metadata(_process_load.bind(aabb))


func place(id:StringName, pos:Vector3, meta := {}) -> bool:
	if not te_list.has(id):
		return false
	var int_pos := Vector3i(pos.floor())
	if BlockManager.set_block(int_pos, &"clonecraft:tileEntity"):
		var te:TileEntity = te_list[id].instantiate()
		te.position = int_pos
		add_child(te)
		te.setup(int_pos, meta)
		te.mark_dirty()
		return true
	else:
		return false
	return false
