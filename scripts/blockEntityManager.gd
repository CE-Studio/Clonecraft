extends Node3D
class_name BlockEntityManager


static var TElist:Dictionary = {
	&"null:null": preload("res://components/InvalidTileEntity.tscn")
}


@onready var terrain:VoxelTerrain = $"../VoxelTerrain"


func _save(aabb:AABB, tool:VoxelTool) -> void:
	var tosave:Array[TileEntity] = []
	for i in get_children():
		if aabb.has_point(i.pos):
			tosave.append(i)
	for i in tosave:
		var rpos := Vector3i(
			i.pos.x % int(aabb.size.x + 1),
			i.pos.y % int(aabb.size.y + 1),
			i.pos.z % int(aabb.size.z + 1),
		)
		var md = tool.get_voxel_metadata(rpos)
		if md is Dictionary:
			md.merge({&"tileEntity": [i.getID(), i.save()]}, true)
		else:
			md = {}
			md.merge({&"tileEntity": [i.getID(), i.save()]}, true)
		tool.set_voxel_metadata(rpos, md)
		i.queue_free()


func _procload(pos:Vector3i, md, aabb:AABB):
	var rpos := aabb.position + Vector3(pos)
	var bi = BlockManager.getBlock(rpos)
	if bi.fullID == &"clonecraft:tileEntity":
		if md is Dictionary:
			if md.has(&"tileEntity"):
				var te = md[&"tileEntity"]
				if TElist.has(te[0]):
					var tile:TileEntity = TElist[te[0]].instantiate()
					tile.position = rpos
					add_child(tile)
					tile.setup(Vector3i(rpos), te[1])


func _load(aabb:AABB, buf:VoxelBuffer) -> void:
	buf.for_each_voxel_metadata(_procload.bind(aabb))
