extends Node

var man
var mat1 = load("res://mods/clonecraft/baseblocks.tres")

func refman(ref):
    man = ref

func _ready():
    pass

func noscript(_pos, _meta) -> void:
    pass
    
var ns := Callable(self, "noscript")

func registerPhase():
    
    var stoneM = man.startBlockRegister("clonecraft:stone")
    stoneM.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    stoneM.collision_enabled_0 = true
    stoneM.cube_tiles_left   = Vector2(3, 0)
    stoneM.cube_tiles_right  = Vector2(3, 0)
    stoneM.cube_tiles_bottom = Vector2(3, 0)
    stoneM.cube_tiles_top    = Vector2(3, 0)
    stoneM.cube_tiles_back   = Vector2(3, 0)
    stoneM.cube_tiles_front  = Vector2(3, 0)
    stoneM.set_material_override(0, mat1)
    stoneM.set_material_override(1, mat1)
    stoneM.set_material_override(2, mat1)
    stoneM.set_material_override(3, mat1)
    stoneM.set_material_override(4, mat1)
    stoneM.set_material_override(5, mat1)
    var stone = BlockManager.BlockInfo.new("clonecraft", "stone", "Stone", stoneM, 3, 5, false, false, ns)
    man.endBlockRegister(stone)
