extends Node3D
class_name TileEntity


@export var itemModel:Mesh


var data:Dictionary
var pos:Vector3i
var ID:StringName:
	get:
		return getID()


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
