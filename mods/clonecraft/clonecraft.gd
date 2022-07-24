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

func quickBlock(bname:String, rname:String, tpos:Vector2, b := 3.0, e := 5.0, t := "pickaxe", ac := 0):
    var model = man.startBlockRegister("clonecraft:" + bname)
    model.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model.collision_enabled_0 = true
    model.transparency_index = ac
    model.cube_tiles_left   = tpos
    model.cube_tiles_right  = tpos
    model.cube_tiles_bottom = tpos
    model.cube_tiles_top    = tpos
    model.cube_tiles_back   = tpos
    model.cube_tiles_front  = tpos
    model.set_material_override(0, mat1)
    var bi = BlockManager.BlockInfo.new("clonecraft", bname, rname, model, b, e, false, false, ns, t)
    man.endBlockRegister(bi)

func makeGB():
    var model = man.startBlockRegister("clonecraft:grassBlock")
    model.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model.collision_enabled_0 = true
    model.transparency_index = 0
    model.cube_tiles_left   = Vector2(2, 0)
    model.cube_tiles_right  = Vector2(2, 0)
    model.cube_tiles_bottom = Vector2(1, 0)
    model.cube_tiles_top    = Vector2(3, 0)
    model.cube_tiles_back   = Vector2(2, 0)
    model.cube_tiles_front  = Vector2(2, 0)
    model.set_material_override(0, mat1)
    var bi = BlockManager.BlockInfo.new("clonecraft", "grassBlock", "Grass Block", model, 1, 1, false, false, ns, "shovel")
    man.endBlockRegister(bi)

func registerPhase():
    quickBlock("stone", "Stone", Vector2(0, 0))
    quickBlock("dirt", "Dirt", Vector2(1, 0), 1, 1, "shovel")
    makeGB()
    quickBlock("cobblestone", "Cobblestone", Vector2(4, 0))
    quickBlock("oreCoal", "Coal Ore", Vector2(5, 0))
    quickBlock("oreIron", "Iron Ore", Vector2(0, 1))
    quickBlock("oreGold", "Gold Ore", Vector2(1, 1))
    quickBlock("oreDiamond", "Diamond Ore", Vector2(2, 1))
    quickBlock("oreEnerstone", "EnerStone Ore", Vector2(3, 1))
    quickBlock("oreCopper", "Copper Ore", Vector2(4, 1))
    quickBlock("tileStone", "Stone Tile", Vector2(5, 1))
