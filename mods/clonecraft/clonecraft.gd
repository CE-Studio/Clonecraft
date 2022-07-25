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
    
func makeCT():
    var model = man.startBlockRegister("clonecraft:craftingBench")
    model.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model.collision_enabled_0 = true
    model.transparency_index = 0
    model.cube_tiles_left   = Vector2(3, 2)
    model.cube_tiles_right  = Vector2(3, 2)
    model.cube_tiles_bottom = Vector2(2, 2)
    model.cube_tiles_top    = Vector2(4, 2)
    model.cube_tiles_back   = Vector2(3, 2)
    model.cube_tiles_front  = Vector2(3, 2)
    model.set_material_override(0, mat1)
    var bi = BlockManager.BlockInfo.new("clonecraft", "craftingBench", "Crafting Workbench", model, 3, 6, false, false, ns, "axe")
    man.endBlockRegister(bi)
    
func makeOL():
    var model1 = man.startBlockRegister("clonecraft:logVertOak")
    model1.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model1.collision_enabled_0 = true
    model1.transparency_index = 0
    model1.cube_tiles_left   = Vector2(5, 2)
    model1.cube_tiles_right  = Vector2(5, 2)
    model1.cube_tiles_bottom = Vector2(1, 3)
    model1.cube_tiles_top    = Vector2(1, 3)
    model1.cube_tiles_back   = Vector2(5, 2)
    model1.cube_tiles_front  = Vector2(5, 2)
    model1.set_material_override(0, mat1)
    var bi1 = BlockManager.BlockInfo.new("clonecraft", "logVertOak", "Vertical Oak Lok", model1, 3, 6, false, false, ns, "axe")
    man.endBlockRegister(bi1)
    
    var model2 = man.startBlockRegister("clonecraft:logHoirz1Oak")
    model2.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model2.collision_enabled_0 = true
    model2.transparency_index = 0
    model2.cube_tiles_left   = Vector2(0, 3)
    model2.cube_tiles_right  = Vector2(0, 3)
    model2.cube_tiles_bottom = Vector2(5, 2)
    model2.cube_tiles_top    = Vector2(5, 2)
    model2.cube_tiles_back   = Vector2(1, 3)
    model2.cube_tiles_front  = Vector2(1, 3)
    model2.set_material_override(0, mat1)
    var bi2 = BlockManager.BlockInfo.new("clonecraft", "logHoirz1Oak", "Horizotal Oak Log 1", model2, 3, 6, false, false, ns, "axe")
    man.endBlockRegister(bi2)
    
    var model3 = man.startBlockRegister("clonecraft:logHoirz2Oak")
    model3.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model3.collision_enabled_0 = true
    model3.transparency_index = 0
    model3.cube_tiles_left   = Vector2(1, 3)
    model3.cube_tiles_right  = Vector2(1, 3)
    model3.cube_tiles_bottom = Vector2(0, 3)
    model3.cube_tiles_top    = Vector2(0, 3)
    model3.cube_tiles_back   = Vector2(0, 3)
    model3.cube_tiles_front  = Vector2(0, 3)
    model3.set_material_override(0, mat1)
    var bi3 = BlockManager.BlockInfo.new("clonecraft", "logHoirz2Oak", "Horizotal Oak Log 2", model3, 3, 6, false, false, ns, "axe")
    man.endBlockRegister(bi3)

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
    quickBlock("brickStone", "Stone Bricks", Vector2(0, 2))
    quickBlock("plankOak", "Oak Planks", Vector2(1, 2))
    quickBlock("tileOak", "Oak Plank Tile", Vector2(2, 2))
    makeCT()
    makeOL()
