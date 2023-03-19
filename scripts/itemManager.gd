extends Node

var items := {}

var _buf := VoxelBuffer.new()
var _mesh := VoxelMesherBlocky.new()

class item:
    var model:Mesh

    func _init(itemMesh:Mesh):
        model = itemMesh


func addToItemLayer(obj:Node) -> Node:
    $/root/Node3D/itemRenderLayer/Camera3D/itemParent.add_child(obj)
    return obj


func getReady() -> void:
    _buf.create(3, 3, 3)
    _mesh.library = BlockManager.blockLibrary


func _process(delta:float) -> void:
    pass


func simpleBlockItemModel(bi:BlockManager.BlockInfo) -> Mesh:
    _buf.set_voxel(BlockManager.blockIDlist[bi.fullID], 1, 1, 1)
    #_buf.fill(BlockManager.blockIDlist[bi.fullID])
    var m:Mesh = _mesh.build_mesh(_buf, _mesh.library.get_materials())
    return m


func simpleBlockItem(bi:BlockManager.BlockInfo) -> item:
    if items.has(bi.fullID):
        return items[bi.fullID]
    var m := simpleBlockItemModel(bi)
    if m == null:
        m = Mesh.new()
    var nitem := item.new(m)
    items[bi.fullID] = nitem
    return nitem


func simpleItemModel():
    pass


func simpleItem() -> item:
    var nitem := item.new(Mesh.new())
    return nitem
