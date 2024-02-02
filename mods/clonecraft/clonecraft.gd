extends Mod

const MODID = &"clonecraft"
var mat1 = load("res://mods/clonecraft/baseblocks.tres")
var mat2 = load("res://mods/clonecraft/baseblocksTransparent.tres")
var canGrass = []

var grassDirs = [
	[-1, 1],  [0, 1],  [1, 1],
	[-1, 0],           [1, 0],
	[-1, -1], [0, -1], [1, -1]
]


func _ready() -> void:
	pass


func runGrass(pos):
	grassDirs.shuffle()
	for i in [1, 0, -1]:
		var rpos = (pos - Vector3i(grassDirs[0][0], i, grassDirs[0][1]))
		if man.getBlock(rpos).fullID in canGrass:
			if man.getBlock(rpos + Vector3i.UP).properties.has(&"air"):
				man.setBlock(rpos, &"clonecraft:grassBlock", false, true, true)
	if not(man.getBlock(pos + Vector3i.UP).properties.has(&"air")):
		man.setBlock(pos, &"clonecraft:dirt", false, true, true)


func _makeGB() -> void:
	var model = man.startBlockRegister("clonecraft:grassBlock", Voxdat.vox.GEOMETRY_CUBE)
	model.set_mesh_collision_enabled(0, true)
	model.transparency_index = 0
	model.tile_left   = Vector2(2, 0)
	model.tile_right  = Vector2(2, 0)
	model.tile_bottom = Vector2(1, 0)
	model.tile_top    = Vector2(3, 0)
	model.tile_back   = Vector2(2, 0)
	model.tile_front  = Vector2(2, 0)
	model.set_material_override(0, mat1)
	var bi := BlockManager.BlockInfo.new(
			"clonecraft",
			"grassBlock",
			"Grass Block",
			model,
			1,
			1,
			false,
			false,
			noScript,
			"shovel",
			"plant",
			"plant",
			"plant"
	)
	bi.setTickable(runGrass)
	man.endBlockRegister(bi)


func _makeCT() -> void:
	var model = man.startBlockRegister("clonecraft:craftingBench", Voxdat.vox.GEOMETRY_CUBE)
	model.set_mesh_collision_enabled(0, true)
	model.transparency_index = 0
	model.tile_left   = Vector2(3, 2)
	model.tile_right  = Vector2(3, 2)
	model.tile_bottom = Vector2(2, 2)
	model.tile_top    = Vector2(4, 2)
	model.tile_back   = Vector2(3, 2)
	model.tile_front  = Vector2(3, 2)
	model.set_material_override(0, mat1)
	var bi = BlockManager.BlockInfo.new(
			"clonecraft",
			"craftingBench",
			"Crafting Workbench",
			model,
			3,
			6,
			false,
			false,
			noScript,
			"axe",
			"wood",
			"wood",
			"wood"
	)
	man.endBlockRegister(bi)


func _makeOL() -> void:
	var model1 = man.startBlockRegister("clonecraft:logVertOak", Voxdat.vox.GEOMETRY_CUBE)
	model1.set_mesh_collision_enabled(0, true)
	model1.transparency_index = 0
	model1.tile_left   = Vector2(5, 2)
	model1.tile_right  = Vector2(5, 2)
	model1.tile_bottom = Vector2(1, 3)
	model1.tile_top    = Vector2(1, 3)
	model1.tile_back   = Vector2(5, 2)
	model1.tile_front  = Vector2(5, 2)
	model1.set_material_override(0, mat1)
	var bi1 = BlockManager.BlockInfo.new(
			"clonecraft",
			"logVertOak",
			"Vertical Oak Lok",
			model1,
			3,
			6,
			false,
			false,
			noScript,
			"axe",
			"wood",
			"wood",
			"wood"
	)
	man.endBlockRegister(bi1)

	var model2 = man.startBlockRegister("clonecraft:logHoirz1Oak", Voxdat.vox.GEOMETRY_CUBE)
	model2.set_mesh_collision_enabled(0, true)
	model2.transparency_index = 0
	model2.tile_left   = Vector2(0, 3)
	model2.tile_right  = Vector2(0, 3)
	model2.tile_bottom = Vector2(5, 2)
	model2.tile_top    = Vector2(5, 2)
	model2.tile_back   = Vector2(1, 3)
	model2.tile_front  = Vector2(1, 3)
	model2.set_material_override(0, mat1)
	var bi2 = BlockManager.BlockInfo.new(
			"clonecraft",
			"logHoirz1Oak",
			"Horizotal Oak Log 1",
			model2,
			3,
			6,
			false,
			false,
			noScript,
			"axe",
			"wood",
			"wood",
			"wood"
	)
	man.endBlockRegister(bi2)

	var model3 = man.startBlockRegister("clonecraft:logHoirz2Oak", Voxdat.vox.GEOMETRY_CUBE)
	model3.set_mesh_collision_enabled(0, true)
	model3.transparency_index = 0
	model3.tile_left   = Vector2(1, 3)
	model3.tile_right  = Vector2(1, 3)
	model3.tile_bottom = Vector2(0, 3)
	model3.tile_top    = Vector2(0, 3)
	model3.tile_back   = Vector2(0, 3)
	model3.tile_front  = Vector2(0, 3)
	model3.set_material_override(0, mat1)
	var bi3 = BlockManager.BlockInfo.new(
			"clonecraft",
			"logHoirz2Oak",
			"Horizotal Oak Log 2",
			model3,
			3,
			6,
			false,
			false,
			noScript,
			"axe",
			"wood",
			"wood",
			"wood"
	)
	man.endBlockRegister(bi3)


func registerPhase() -> void:
	man.quickUniformBlock(MODID, "stone", "Stone", Vector2(0, 0), mat1)
	man.quickUniformBlock(MODID, "dirt", "Dirt", Vector2(1, 0), mat1, 1, 1, "shovel")
	canGrass.append("clonecraft:dirt")
	_makeGB()
	man.quickUniformBlock(MODID, "cobblestone", "Cobblestone", Vector2(4, 0), mat1)
	man.quickUniformBlock(MODID, "oreCoal", "Coal Ore", Vector2(5, 0), mat1)
	man.quickUniformBlock(MODID, "oreIron", "Iron Ore", Vector2(0, 1), mat1)
	man.quickUniformBlock(MODID, "oreGold", "Gold Ore", Vector2(1, 1), mat1)
	man.quickUniformBlock(MODID, "oreDiamond", "Diamond Ore", Vector2(2, 1), mat1)
	man.quickUniformBlock(MODID, "oreEnerstone", "EnerStone Ore", Vector2(3, 1), mat1)
	man.quickUniformBlock(MODID, "oreCopper", "Copper Ore", Vector2(4, 1), mat1)
	man.quickUniformBlock(MODID, "tileStone", "Stone Tile", Vector2(5, 1), mat1)
	man.quickUniformBlock(MODID, "brickStone", "Stone Bricks", Vector2(0, 2), mat1)
	man.quickUniformBlock(MODID, "plankOak", "Oak Planks", Vector2(1, 2), mat1, 3, 6, "axe")
	man.quickUniformBlock(MODID, "tileOak", "Oak Plank Tile", Vector2(2, 2), mat1, 3, 6, "axe")
	_makeCT()
	_makeOL()
	man.quickUniformBlock(MODID, "barkOak", "Oak Bark", Vector2(5, 2), mat1, 3, 6, "axe")
	man.quickUniformBlock(MODID, "knotOak", "Oak Knot", Vector2(1, 3), mat1, 3, 6, "axe")
	man.quickUniformBlock(MODID, "leavesOak", "Oak Leaves", Vector2(2, 3), mat2, 1, 1, "shears", 1)
	man.quickUniformBlock(MODID, "gravel", "Gravel", Vector2(3, 3), mat1, 1, 1, "shovel")
	man.quickUniformBlock(MODID, "sand", "Sand", Vector2(4, 3), mat1, 1, 1, "shovel")
	man.quickUniformBlock(MODID, "glass", "Glass", Vector2(5, 3), mat2, 1, 1, "pickaxe", 2)
	man.quickUniformBlock(MODID, "brick", "Brick", Vector2(0, 4), mat1)
	man.quickUniformBlock(MODID, "clay", "Clay", Vector2(1, 4), mat1, 1, 1, "shovel")
	man.quickUniformBlock(MODID, "blockCoal", "Coal Block", Vector2(2, 4), mat1)
	man.quickUniformBlock(MODID, "blockIron", "Coal Block", Vector2(3, 4), mat1)
	man.quickUniformBlock(MODID, "blockGold", "Coal Block", Vector2(4, 4), mat1)
	man.quickUniformBlock(MODID, "blockDiamond", "Coal Block", Vector2(5, 4), mat2, 3, 5, "pickaxe", 2)
	man.quickUniformBlock(MODID, "blockEnerstone", "EnerStone Crate", Vector2(0, 5), mat1)
	man.quickUniformBlock(MODID, "blockCopper", "Copper Block", Vector2(1, 5), mat1)
