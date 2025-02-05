extends Node
class_name ItemManager
## Creates and manages items.

## A dictionary containing all registered items.
static var items := {}
## A preloaded blank [WorldItem].
static var witem:PackedScene = preload("res://scripts/itemAssets/worldItem.tscn")
static var _buf := VoxelBuffer.new()
static var _mesh := VoxelMesherBlocky.new()


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
	
	## Create a copy of this ItemStack
	func copy() -> ItemStack:
		return ItemStack.new(itemID, count, metadata)
	
	## Return the model of the contained item.
	func getModel() -> ItemModel:
		return getItem().model
		
	## Return the contained item.
	func getItem() -> Item:
		if ItemManager.items.has(itemID):
			return ItemManager.items[itemID]
		else:
			return ItemManager.simpleItem()
		
	## Checks if two ItemStacks are identical, ignoring count.
	func compare(compTo: ItemStack, ignoreDamage := false, ignoreEnergy := false) -> bool:
		if itemID != compTo.itemID:
			return false
		if compTo.metadata.has_all(metadata.keys()) && metadata.has_all(compTo.metadata.keys()):
			for i in metadata.keys():
				if ignoreDamage and i == "damage":
					continue
				if ignoreEnergy and i == "energy":
					continue
				if metadata[i] != compTo.metadata[i]:
					return false
		else:
			return false
		return true


class ItemModel extends RefCounted:
	var is3D:bool
	var texture:Texture2D
	var mesh:Mesh
	var atlasSize:Vector2i
	var frame:Vector2i
	var animateFrame:Callable
	
	
	static func make2D(iTexture:Texture2D, iAtlasSize:Vector2i, iFrame:Vector2i, iAnimateFrame:Callable = Callable()) -> ItemModel:
		var m = ItemModel.new()
		m.is3D = false
		m.texture = iTexture
		m.atlasSize = iAtlasSize
		m.animateFrame = iAnimateFrame
		m.frame = iFrame
		return m
	
	
	static func make3D(iMesh:Mesh) -> ItemModel:
		var m = ItemModel.new()
		m.is3D = true
		m.mesh = iMesh
		return m


## A container for static item properties.
class Item extends RefCounted:
	var model:ItemModel
	var name:StringName
	
	var hasInteractionOverride := false
	var interactionOverride:Callable
	var consumeOnInteract := 0


	var isTool := false
	var toolClass:StringName
	var toolPower:float
	var toolBaseDurability:float


	var isVoxel := false
	var voxel:StringName
	var ponderScene:PackedScene


	func _init(itemModel:ItemModel):
		model = itemModel
	
	
	## Allows items to intercept place/break events.[br]
	## Expects the function to return a [bool]. True to mark the event as handled, and false to continue processing the event normally.
	func setInteractionOverride(i:Callable):
		hasInteractionOverride = true
		interactionOverride = i
	
	
	## Marks the item as a tool of the given type toolclass, for example: "tools:pickaxe"
	func setToolClass(toolclass:StringName, power:float = 1, durability:float = -1):
		isTool = true
		toolClass = toolclass
		toolPower = power
		toolBaseDurability = durability
	
	
	## Marks the item as being placable.
	func setVoxel(vox:StringName):
		isVoxel = true
		voxel = vox


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
		m = ArrayMesh.new()
	var im := ItemModel.make3D(m)
	var nitem := registerItem(bi.fullID, bi.nameReadable, im)
	nitem.setVoxel(bi.fullID)
	return nitem


static func registerItem(id:StringName, nameReadable:StringName, model:ItemModel) -> Item:
	if items.has(id):
		return items[id]
	var nitem := Item.new(model)
	nitem.name = nameReadable
	items[id] = nitem
	return nitem


## Creates a blank [ItemManager.Item]
static func simpleItem() -> Item:
	var nitem := Item.new(ItemModel.make2D(preload("res://textures/missing16.png"), Vector2i.ONE, Vector2i.ZERO))
	return nitem


## Spawns an item entity in the world.
static func spawnWorldItem(itemStack:ItemStack, pos:Vector3, vel:Vector3 = Vector3(0, 2, 0)) -> WorldItem:
	var nitem:WorldItem = witem.instantiate()
	nitem.position = pos
	nitem.apply_central_impulse(vel)
	nitem.setItem(itemStack)
	Statics.get_node("/root/Node3D").add_child(nitem)
	return nitem
