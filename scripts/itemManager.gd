extends Node
class_name ItemManager
## Creates and manages items.

## A dictionary containing all registered items.
static var items:Dictionary[StringName, Item] = {}
## A preloaded blank [WorldItem].
static var world_item:PackedScene = preload("res://scripts/itemAssets/worldItem.tscn")
static var _buf := VoxelBuffer.new()
static var _mesh := VoxelMesherBlocky.new()


## A wrapper for items. 99% of the time you want to use this instead of an item object.
class ItemStack extends RefCounted:
	## The ID of the contained item(s) (mod:name)
	var item_ID:StringName
	## The number of items in the stack.
	var count:int
	## Generic data storage. Can contain anything.
	var metadata:Dictionary[String, Variant]
	## a
	func _init(iid:StringName, icount:int, imetadata:Dictionary[String, Variant] = {}):
		item_ID = iid
		count = icount
		metadata.assign(get_item().static_meta.duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL))
		for i in metadata:
			if metadata[i] is Callable:
				metadata[i] = metadata[i].call(self)
		metadata.merge(imetadata, true)
	
	## Create a copy of this ItemStack
	func copy() -> ItemStack:
		return ItemStack.new(item_ID, count, metadata)
	
	## Return the model of the contained item.
	func get_model() -> ItemModel:
		return get_item().model
		
	## Return the contained item.
	func get_item() -> Item:
		if ItemManager.items.has(item_ID):
			return ItemManager.items[item_ID]
		else:
			return ItemManager.simpleItem()
		
	## Checks if two ItemStacks are identical, ignoring count.
	func compare(compTo: ItemStack, ignoreDamage := false, ignoreEnergy := false) -> bool:
		if item_ID != compTo.item_ID:
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
	var is_3D:bool
	var texture:Texture2D
	var mesh:Mesh
	var atlas_size:Vector2i
	var frame:Vector2i
	var animate_frame:Callable
	
	
	static func make_2D(_texture:Texture2D, _atlas_size:Vector2i, _frame:Vector2i, _animate_frame:Callable = Callable()) -> ItemModel:
		var m = ItemModel.new()
		m.is_3D = false
		m.texture = _texture
		m.atlas_size = _atlas_size
		m.animate_frame = _animate_frame
		m.frame = _frame
		return m
	
	
	static func make_3D(iMesh:Mesh) -> ItemModel:
		var m = ItemModel.new()
		m.is_3D = true
		m.mesh = iMesh
		return m


## A container for static item properties.
class Item extends RefCounted:
	var model:ItemModel
	var name:StringName
	
	var has_interaction_override := false
	var interaction_override:Callable
	var consume_on_interact := 0


	var is_tool := false
	var tool_class:StringName
	var tool_power:float
	var tool_base_durability:float


	var is_voxel := false
	var voxel:StringName
	var ponder_scene:StringName
	var static_meta:Dictionary = {}


	func _init(item_model:ItemModel):
		model = item_model
	
	
	## Allows items to intercept place/break events.[br]
	## Expects the function to return a [bool]. True to mark the event as handled, and false to continue processing the event normally.
	func set_interaction_override(i:Callable) -> Item:
		has_interaction_override = true
		interaction_override = i
		return self
	
	
	## Marks the item as a tool of the given type tool class, for example: "tools:pickaxe"
	func setToolClass(_tool_class:StringName, power:float = 1, durability:float = -1) -> Item:
		is_tool = true
		tool_class = _tool_class
		tool_power = power
		tool_base_durability = durability
		return self
	
	
	## Marks the item as being placable.
	func setVoxel(vox:StringName) -> Item:
		is_voxel = true
		voxel = vox
		return self


## Sets up the buffer and block library for generating item models.
static func get_ready() -> void:
	_buf.create(3, 3, 3)
	_mesh.library = BlockManager.block_library


## Generates an item model for the given block.
static func simple_block_item_model(bi:BlockManager.BlockInfo) -> Mesh:
	_buf.set_voxel(BlockManager.block_id_list[bi.full_id], 1, 1, 1)
	#_buf.fill(BlockManager.block_id_list[bi.full_id])
	var m:Mesh = _mesh.build_mesh(_buf, _mesh.library.get_materials())
	return m


## The easiest way to make an item for a block.[br]
## Gets called automatically if you haven't given your block an item on your own.
static func simple_block_item(bi:BlockManager.BlockInfo) -> Item:
	if items.has(bi.full_id):
		return items[bi.full_id]
	var m := simple_block_item_model(bi)
	if m == null:
		m = ArrayMesh.new()
	var im := ItemModel.make_3D(m)
	var new_item := register_item(bi.full_id, bi.name_readable, im)
	new_item.setVoxel(bi.full_id)
	return new_item


static func register_item(id:StringName, name_readable:StringName, model:ItemModel) -> Item:
	if items.has(id):
		return items[id]
	var new_item := Item.new(model)
	new_item.name = name_readable
	items[id] = new_item
	return new_item


## Creates a blank [ItemManager.Item]
static func simpleItem() -> Item:
	var new_item := Item.new(ItemModel.make_2D(preload("res://textures/missing16.png"), Vector2i.ONE, Vector2i.ZERO))
	return new_item


## Spawns an item entity in the world.
static func spawn_world_item(itemStack:ItemStack, pos:Vector3, vel:Vector3 = Vector3(0, 2, 0)) -> WorldItem:
	var new_item:WorldItem = world_item.instantiate()
	new_item.position = pos + (vel / 100)
	new_item.apply_central_impulse(vel)
	new_item.set_item(itemStack)
	Statics.get_node("/root/Node3D").add_child(new_item)
	return new_item
