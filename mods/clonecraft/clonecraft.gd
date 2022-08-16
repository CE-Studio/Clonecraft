extends Mod

const MODID = "clonecraft"
var mat1 = load("res://mods/clonecraft/baseblocks.tres")
var mat2 = load("res://mods/clonecraft/baseblocksTransparent.tres")
var canGrass = []


func _ready():
	pass


func runGrass(pos):
	man.log(MODID, "trying to grass")
	var dirs = [
		[-1, 1],  [0, 1],  [1, 1],
		[-1, 0],           [1, 0],
		[-1, -1], [0, -1], [1, -1]
	]
	dirs.shuffle()
	for i in [1, 0, -1]:
		var rpos = (pos - Vector3i(dirs[0][0], i, dirs[0][1]))
		var vt = man.blockList[tool.get_voxel(rpos)]
		if vt.fullID in canGrass:
			if man.blockList[tool.get_voxel(rpos + Vector3i.UP)].isAir:
				tool.set_voxel(rpos, man.blockIDlist["clonecraft:grassBlock"])
	if not(man.blockList[tool.get_voxel(pos + Vector3i.UP)].isAir):
		tool.set_voxel(pos, man.blockIDlist["clonecraft:dirt"])


func quickBlock(
		blockName:String,
		readableName:String,
		texturePos:Vector2,
		breakStrength := 3.0,
		explStrength := 5.0,
		tool := "pickaxe",
		alphaChannel := 0):
	var model = man.startBlockRegister("clonecraft:" + blockName)
	model.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
	model.collision_enabled_0 = true
	model.transparency_index = alphaChannel
	model.cube_tiles_left   = texturePos
	model.cube_tiles_right  = texturePos
	model.cube_tiles_bottom = texturePos
	model.cube_tiles_top    = texturePos
	model.cube_tiles_back   = texturePos
	model.cube_tiles_front  = texturePos
	if alphaChannel == 0:
		model.set_material_override(0, mat1)
	else:
		model.set_material_override(0, mat2)
	var bi = BlockManager.BlockInfo.new(
			"clonecraft",
			blockName,
			readableName,
			model,
			breakStrength,
			explStrength,
			false,
			false,
			noScript,
			tool
	)
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
			"shovel"
	)
	bi.setTickable(runGrass)
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
			"axe"
	)
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
			"axe"
	)
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
			"axe"
	)
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
			"axe"
	)
	man.endBlockRegister(bi3)


func registerPhase():
	quickBlock("stone", "Stone", Vector2(0, 0))
	quickBlock("dirt", "Dirt", Vector2(1, 0), 1, 1, "shovel")
	canGrass.append("clonecraft:dirt")
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
	quickBlock("plankOak", "Oak Planks", Vector2(1, 2), 3, 6, "axe")
	quickBlock("tileOak", "Oak Plank Tile", Vector2(2, 2), 3, 6, "axe")
	makeCT()
	makeOL()
	quickBlock("barkOak", "Oak Bark", Vector2(5, 2), 3, 6, "axe")
	quickBlock("knotOak", "Oak Knot", Vector2(1, 3), 3, 6, "axe")
	quickBlock("leavesOak", "Oak Leaves", Vector2(2, 3), 1, 1, "shears", 1)
	quickBlock("gravel", "Gravel", Vector2(3, 3), 1, 1, "shovel")
	quickBlock("sand", "Sand", Vector2(4, 3), 1, 1, "shovel")
	quickBlock("glass", "Glass", Vector2(5, 3), 1, 1, "pickaxe", 2)
	quickBlock("brick", "Brick", Vector2(0, 4))
	quickBlock("clay", "Clay", Vector2(1, 4), 1, 1, "shovel")
	quickBlock("blockCoal", "Coal Block", Vector2(2, 4))
	quickBlock("blockIron", "Coal Block", Vector2(3, 4))
	quickBlock("blockGold", "Coal Block", Vector2(4, 4))
	quickBlock("blockDiamond", "Coal Block", Vector2(5, 4), 3, 5, "pickaxe", 2)
	quickBlock("blockEnerstone", "EnerStone Crate", Vector2(0, 5))
	quickBlock("blockCopper", "Copper Block", Vector2(1, 5))
