extends Node
class_name ItemManager
## Creates and manages items.

## A dictionary containing all registered items.
static var items:Dictionary[StringName, Item] = {}
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
	var metadata:Dictionary[String, Variant]
	## a
	func _init(iid:StringName, icount:int, imetadata:Dictionary[String, Variant] = {}):
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
	var tool_class:StringName
	var toolPower:float
	var toolBaseDurability:float


	var isVoxel := false
	var voxel:StringName
	var ponderScene:StringName


	func _init(itemModel:ItemModel):
		model = itemModel
	
	
	## Allows items to intercept place/break events.[br]
	## Expects the function to return a [bool]. True to mark the event as handled, and false to continue processing the event normally.
	func setInteractionOverride(i:Callable) -> Item:
		hasInteractionOverride = true
		interactionOverride = i
		return self
	
	
	## Marks the item as a tool of the given type toolclass, for example: "tools:pickaxe"
	func setToolClass(toolclass:StringName, power:float = 1, durability:float = -1) -> Item:
		isTool = true
		tool_class = toolclass
		toolPower = power
		toolBaseDurability = durability
		return self
	
	
	## Marks the item as being placable.
	func setVoxel(vox:StringName) -> Item:
		isVoxel = true
		voxel = vox
		return self


## Sets up the buffer and block library for generating item models.
static func getReady() -> void:
	_buf.create(3, 3, 3)
	_mesh.library = BlockManager.block_library


## Generates an item model for the given block.
static func simpleBlockItemModel(bi:BlockManager.BlockInfo) -> Mesh:
	_buf.set_voxel(BlockManager.block_id_list[bi.full_id], 1, 1, 1)
	#_buf.fill(BlockManager.block_id_list[bi.full_id])
	var m:Mesh = _mesh.build_mesh(_buf, _mesh.library.get_materials())
	return m


## The easiest way to make an item for a block.[br]
## Gets called automatically if you haven't given your block an item on your own.
static func simpleBlockItem(bi:BlockManager.BlockInfo) -> Item:
	if items.has(bi.full_id):
		return items[bi.full_id]
	var m := simpleBlockItemModel(bi)
	if m == null:
		m = ArrayMesh.new()
	var im := ItemModel.make3D(m)
	var nitem := registerItem(bi.full_id, bi.name_readable, im)
	nitem.setVoxel(bi.full_id)
	return nitem


static func registerItem(id:StringName, name_readable:StringName, model:ItemModel) -> Item:
	if items.has(id):
		return items[id]
	var nitem := Item.new(model)
	nitem.name = name_readable
	items[id] = nitem
	return nitem


## Creates a blank [ItemManager.Item]
static func simpleItem() -> Item:
	var nitem := Item.new(ItemModel.make2D(preload("res://textures/missing16.png"), Vector2i.ONE, Vector2i.ZERO))
	return nitem


## Spawns an item entity in the world.
static func spawnWorldItem(itemStack:ItemStack, pos:Vector3, vel:Vector3 = Vector3(0, 2, 0)) -> WorldItem:
	var nitem:WorldItem = witem.instantiate()
	nitem.position = pos + (vel / 100)
	nitem.apply_central_impulse(vel)
	nitem.setItem(itemStack)
	Statics.get_node("/root/Node3D").add_child(nitem)
	return nitem
