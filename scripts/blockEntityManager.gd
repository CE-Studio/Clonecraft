extends Node3D
class_name BlockEntityManager


static var TElist:Dictionary = {
	&"null:null": preload("res://components/InvalidTileEntity.tscn")
}
static var instance:BlockEntityManager


@onready var terrain:VoxelTerrain = $"../VoxelTerrain"


func  _ready() -> void:
	instance = self


func _save(aabb:AABB, tool:VoxelTool) -> void:
	for i in _saveChunk(aabb, tool):
		i.queue_free()


func _clear(aabb:AABB) -> void:
	for i in get_children():
		if i is TileEntity:
			if aabb.has_point(i.pos):
				i.queue_free()


func _saveChunk(aabb:AABB, tool:VoxelTool) -> Array[TileEntity]:
	#DebugAABB.instance.aabb = aabb
	#print("savin")
	var tosave:Array[TileEntity] = []
	for i in get_children():
		if i is TileEntity:
			if aabb.has_point(i.pos):
				#print("found at ", i.pos)
				tosave.append(i)
	for i in tosave:
		var rpos := Vector3i(
			posmod(i.pos.x, int(aabb.size.x)),
			posmod(i.pos.y, int(aabb.size.y)),
			posmod(i.pos.z, int(aabb.size.z)),
		)
		#print("relative ", rpos)
		var md = tool.get_voxel_metadata(rpos)
		if md is Dictionary:
			md.merge({&"tileEntity": [i.getID(), i.save()]}, true)
		else:
			md = {}
			md.merge({&"tileEntity": [i.getID(), i.save()]}, true)
		tool.set_voxel_metadata(rpos, md)
	return tosave


func _procload(pos:Vector3i, md, aabb:AABB):
	var rpos := aabb.position + Vector3(pos)
	#print("loadin ",rpos)
	var bi = BlockManager.getBlock(rpos)
	if bi.fullID == &"clonecraft:tileEntity":
		#print("is te")
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


func place(id:StringName, pos:Vector3, meta := {}) -> bool:
	if not TElist.has(id):
		return false
	var ipos := Vector3i(pos.floor())
	if BlockManager.setBlock(ipos, &"clonecraft:tileEntity"):
		var te:TileEntity = TElist[id].instantiate()
		te.position = ipos
		add_child(te)
		te.setup(ipos, meta)
		te.markDirty()
		return true
	else:
		return false
	return false
