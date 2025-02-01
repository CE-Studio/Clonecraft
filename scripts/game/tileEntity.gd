extends Node3D
class_name TileEntity


@export var itemModel:Mesh


var data:Dictionary
var pos:Vector3i
var ID:StringName:
	get:
		return getID()


## Override with your TileEntity's ID
func getID() -> StringName:
	return &"null:null"


## Called when the TileEntity enters the scene tree for the first time.
func _ready() -> void:
	pass


## Called every world tick. 'delta' is the elapsed time since the previous tick.
func _tick(delta: float) -> void:
	pass


## Called whenever the TileEntity recives a block update.
func _blockUpdate() -> void:
	pass


## Called when the tile entity is added to the scene, after [code]_ready[/code].
func setup(ipos:Vector3i, idata:Dictionary) -> void:
	pos = ipos
	if idata != null:
		data.merge(idata, true)


## Called whenever a tile needs to be saved.
func save() -> Dictionary:
	return data


## Call to flag that the TileEntity needs to be re-saved.[br]
## The TileEntity may still be re-saved even if you don't call this.
func markDirty() -> void:
	WorldControl.markDirty(Vector3i((pos / 16.0).floor()))
