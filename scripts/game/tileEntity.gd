extends Node3D
class_name TileEntity


var data:Dictionary
var pos:Vector3i
var ID:StringName


## Called when the TileEntity enters the scene tree for the first time.
func _ready() -> void:
	pass


## Called every world tick. 'delta' is the elapsed time since the previous tick.
func _tick(delta: float) -> void:
	pass


## Called whenever the TileEntity recives a block update.
func _blockUpdate() -> void:
	pass


## Called when the tile entity is added to the scene, after [code]_ready[/code].[br]
## Returns [code]true[/code] if it sucessfully loaded save data from the world, otherwise [code]false[/code].[br]
## A falure does NOT indicate a problem, just that no data was found. This is expected, for example, when a new TileEntity is just placed.
func setup(iID:StringName, ipos:Vector3i) -> bool:
	pos = ipos
	ID = iID
	var md = BlockManager._tool.get_voxel_metadata(pos)
	if md is Dictionary:
		if ID in md.keys():
			if md[ID] is Dictionary:
				data.merge(md[ID], true)
				return true
	return false


## Called whenever a tile needs to be saved.[br]
## Returns [code]true[/code] if saving was sucessfull.
func save() -> bool:
	var md = BlockManager._tool.get_voxel_metadata(pos)
	if md == null:
		md = {}
	if md is Dictionary:
		md.merge({ID : data}, true)
		BlockManager._tool.set_voxel_metadata(pos, md)
		return true
	return false
