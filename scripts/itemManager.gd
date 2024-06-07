extends Node
class_name ItemManager
## Creates and manages items.

## A dictionary containing all registered items.
static var items := {}
## A preloaded blank [WorldItem].
static var witem:PackedScene = preload("res://scripts/itemAssets/worldItem.tscn")
static var _buf := VoxelBuffer.new()
static var _mesh := VoxelMesherBlocky.new()
## Keeps track of the screen size for rendering reasons.
static var screenSize := Vector2(100, 100)


## A wrapper for items. 99% of the time you want to use this instead of an item object.
class ItemStack extends RefCounted:
	## The ID of the contained item(s) (mod:name)
	var itemID:StringName
	## The number of items in the stack.
	var count:int
	## Generic data storage. Can contain anything.
	var metadata:Dictionary
	## a
	func _init(iid:StringName, icount:int, imetadata:Dictionary = {}):
		itemID = iid
		count = icount
		metadata = imetadata

	## Return the model of the contained item.
	func getMesh() -> Mesh:
		return getItem().model
		
	## Return the contained item.
	func getItem() -> Item:
		return ItemManager.items[itemID]
		
	## Checks if two ItemStacks are identical, ignoring count.
	func compare(compTo: ItemStack) -> bool:
		if itemID != compTo.itemID:
			return false
		if compTo.metadata.has_all(metadata.keys()) && metadata.has_all(compTo.metadata.keys()):
			for i in metadata.keys():
				if metadata[i] != compTo.metadata[i]:
					return false
		else:
			return false
		return true


## A container for static item properties.[br]
## Currently just the item's model.
class Item extends RefCounted:
	var model:Mesh

	func _init(itemMesh:Mesh):
		model = itemMesh


## Parents a node to the item rendering layer to draw on-screen.[br]
## The item rendering layer is orthographic 3D.
static func addToItemLayer(obj:Node) -> Node:
	Statics.get_node("/root/Node3D/itemRenderLayer/Camera3D/itemParent").add_child(obj)
	return obj


## Sets up the buffer and block library for generating item models.
static func getReady() -> void:
	_buf.create(3, 3, 3)
	_mesh.library = BlockManager.blockLibrary


## Generates an item model for the given block.
static func simpleBlockItemModel(bi:BlockManager.BlockInfo) -> Mesh:
	_buf.set_voxel(BlockManager.blockIDlist[bi.fullID], 1, 1, 1)
	#_buf.fill(BlockManager.blockIDlist[bi.fullID])
	var m:Mesh = _mesh.build_mesh(_buf, _mesh.library.get_materials())
	return m


## The easiest way to make an item for a block.[br]
## Gets called automatically if you haven't given your block an item on your own.
static func simpleBlockItem(bi:BlockManager.BlockInfo) -> Item:
	if items.has(bi.fullID):
		return items[bi.fullID]
	var m := simpleBlockItemModel(bi)
	if m == null:
		m = Mesh.new()
	var nitem := Item.new(m)
	items[bi.fullID] = nitem
	return nitem


# TODO simple item model
static func simpleItemModel():
	pass


## Creates a blank [ItemManager.Item]
static func simpleItem() -> Item:
	var nitem := Item.new(Mesh.new())
	return nitem


## Spawns an item entity in the world.
static func spawnWorldItem(itemStack:ItemStack, pos:Vector3, vel:Vector3 = Vector3(0, 2, 0)) -> WorldItem:
	var nitem:WorldItem = witem.instantiate()
	nitem.position = pos
	nitem.apply_central_impulse(vel)
	nitem.setItem(itemStack)
	Statics.get_node("/root/Node3D").add_child(nitem)
	return nitem


static func posConvert(pos:Vector2) -> Vector3:
	pos = Vector2(pos)
	pos.x -= (screenSize.x /2)
	pos.y -= (screenSize.y /2)
	pos = pos / 30
	return Vector3(pos.x, -pos.y, 0)
