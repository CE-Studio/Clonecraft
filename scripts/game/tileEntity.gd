extends StaticBody3D
class_name TileEntity


@export var itemModel:Mesh


var data:Dictionary
var pos:Vector3i
var ID:StringName:
	get:
		return get_id()


## Override with your TileEntity's ID
func get_id() -> StringName:
	return &"null:null"


## Called when the TileEntity enters the scene tree for the first time.
func _ready() -> void:
	pass


func interact(event:InputEvent) -> bool:
	return false


## Called every world tick. 'delta' is the elapsed time since the previous tick.
func _tick(delta: float) -> void:
	pass


## Called whenever the TileEntity receives a block update.
func _block_update() -> void:
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
func mark_dirty() -> void:
	WorldControl.mark_dirty(Vector3i((pos / 16.0).floor()))
