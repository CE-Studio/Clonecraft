extends Node
class_name ItemManager
## Creates and manages items.

## A dictionary 
static var items := {}
static var witem:PackedScene = preload("res://scripts/itemAssets/worldItem.tscn")

static var _buf := VoxelBuffer.new()
static var _mesh := VoxelMesherBlocky.new()
static var screenSize := Vector2(100, 100)


class ItemStack:
    var id:String
    var count:int

    func _init(iid:String, icount:int):
        id = iid
        count = icount

    func getMesh() -> Mesh:
        return ItemManager.items[id].model


class Item:
    var model:Mesh

    func _init(itemMesh:Mesh):
        model = itemMesh


static func addToItemLayer(obj:Node) -> Node:
    Statics.get_node("/root/Node3D/itemRenderLayer/Camera3D/itemParent").add_child(obj)
    return obj


static func getReady() -> void:
    _buf.create(3, 3, 3)
    _mesh.library = BlockManager.blockLibrary


static func simpleBlockItemModel(bi:BlockManager.BlockInfo) -> Mesh:
    _buf.set_voxel(BlockManager.blockIDlist[bi.fullID], 1, 1, 1)
    #_buf.fill(BlockManager.blockIDlist[bi.fullID])
    var m:Mesh = _mesh.build_mesh(_buf, _mesh.library.get_materials())
    return m


static func simpleBlockItem(bi:BlockManager.BlockInfo) -> Item:
    if items.has(bi.fullID):
        return items[bi.fullID]
    var m := simpleBlockItemModel(bi)
    if m == null:
        m = Mesh.new()
    var nitem := Item.new(m)
    items[bi.fullID] = nitem
    return nitem


static func simpleItemModel():
    pass


static func simpleItem() -> Item:
    var nitem := Item.new(Mesh.new())
    return nitem


static func spawnWorldItem(itemStack:ItemStack, pos:Vector3, vel:Vector3 = Vector3(0, 2, 0)) -> WorldItem:
    var nitem:WorldItem = witem.instantiate()
    nitem.position = pos
    nitem.apply_central_impulse(vel)
    nitem.setItem(itemStack)
    Statics.get_node("/root/Node3D").add_child(nitem)
    return nitem
