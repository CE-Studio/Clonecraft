extends Node


class item:
    var model:Node3D
    
    func _init():
        pass

func _ready() -> void:
    pass


func _process(delta:float) -> void:
    pass


func simpleBlockItemModel():
    pass


func simpleBlockItem(bi:BlockManager.BlockInfo) -> item:
    var nitem := item.new()
    var mesh := MeshInstance3D.new()
    var bmod := bi.blockModel
    var uvarray := []
    return nitem


func simpleItemModel():
    pass


func simpleItem() -> item:
    var nitem := item.new()
    return nitem
