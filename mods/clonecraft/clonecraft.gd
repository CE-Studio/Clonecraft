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
			"clonecraft.block.grass_block",
			model,
			1,
			1,
			false,
			false,
			noScript,
			"tools:shovel",
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
			"clonecraft.block.crafting_bench",
			model,
			3,
			6,
			false,
			false,
			noScript,
			"tools:axe",
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
			"clonecraft.block.oak_log_vert",
			model1,
			3,
			6,
			false,
			false,
			noScript,
			"tools:axe",
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
			"clonecraft.block.oak_log_horiz_1",
			model2,
			3,
			6,
			false,
			false,
			noScript,
			"tools:axe",
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
			"clonecraft.block.oak_log_horiz_2",
			model3,
			3,
			6,
			false,
			false,
			noScript,
			"tools:axe",
			"wood",
			"wood",
			"wood"
	)
	man.endBlockRegister(bi3)


func _makeItems() -> void:
	var t:Texture2D = load("res://mods/clonecraft/items.png")
	var s:Vector2i = Vector2i(10, 10)
	ItemManager.registerItem(&"clonecraft:stick", &"clonecraft.item.stick", ItemManager.ItemModel.make2D(
		t,
		s,
		Vector2i(0, 0)
	))


func blockFall(pos:Vector3) -> void:
	if man.getBlock(pos + Vector3.DOWN).properties.has(&"air"):
		WorldControl.instance.spawnFallingBlock(pos)


func registerPhase() -> void:
	Translator.loadFromJson("res://mods/clonecraft/lang/en_us.json")
	CMDprocessor.registerCommand(load("res://mods/clonecraft/cmd/give.gd").new())
	CMDprocessor.registerCommand(load("res://mods/clonecraft/cmd/editbar.gd").new())
	man.quickUniformBlock(MODID, "stone", "clonecraft.block.stone", Vector2(0, 0), mat1)
	man.quickUniformBlock(MODID, "dirt", "clonecraft.block.dirt", Vector2(1, 0), mat1, 1, 1, "tools:shovel")
	canGrass.append("clonecraft:dirt")
	_makeGB()
	man.quickUniformBlock(MODID, "cobblestone", "clonecraft.block.cobblestone", Vector2(4, 0), mat1)
	man.quickUniformBlock(MODID, "oreCoal", "clonecraft.block.coal_ore", Vector2(5, 0), mat1)
	man.quickUniformBlock(MODID, "oreIron", "clonecraft.block.iron_ore", Vector2(0, 1), mat1)
	man.quickUniformBlock(MODID, "oreGold", "clonecraft.block.gold_ore", Vector2(1, 1), mat1)
	man.quickUniformBlock(MODID, "oreDiamond", "clonecraft.block.diamond_ore", Vector2(2, 1), mat1)
	man.quickUniformBlock(MODID, "oreEnerstone", "clonecraft.block.enerstone_ore", Vector2(3, 1), mat1)
	man.quickUniformBlock(MODID, "oreCopper", "clonecraft.block.copper_ore", Vector2(4, 1), mat1)
	man.quickUniformBlock(MODID, "tileStone", "clonecraft.block.stone_tile", Vector2(5, 1), mat1)
	man.quickUniformBlock(MODID, "brickStone", "clonecraft.block.stone_bricks", Vector2(0, 2), mat1)
	man.quickUniformBlock(MODID, "plankOak", "clonecraft.block.oak_planks", Vector2(1, 2), mat1, 3, 6, "tools:axe")
	man.quickUniformBlock(MODID, "tileOak", "clonecraft.block.oak_plank_tile", Vector2(2, 2), mat1, 3, 6, "tools:axe")
	_makeCT()
	_makeOL()
	man.quickUniformBlock(MODID, "barkOak", "clonecraft.block.oak_bark", Vector2(5, 2), mat1, 3, 6, "tools:axe")
	man.quickUniformBlock(MODID, "knotOak", "clonecraft.block.oak_knot", Vector2(1, 3), mat1, 3, 6, "tools:axe")
	man.quickUniformBlock(MODID, "leavesOak", "clonecraft.block.oak_leaves", Vector2(2, 3), mat2, 1, 1, "tools:shears", 1)
	man.quickUniformBlock(MODID, "gravel", "clonecraft.block.gravel", Vector2(3, 3), mat1, 1, 1, "tools:shovel").setScripted(blockFall)
	man.quickUniformBlock(MODID, "sand", "clonecraft.block.sand", Vector2(4, 3), mat1, 1, 1, "tools:shovel").setScripted(blockFall)
	man.quickUniformBlock(MODID, "glass", "clonecraft.block.glass", Vector2(5, 3), mat2, 1, 1, "tools:pickaxe", 2)
	man.quickUniformBlock(MODID, "brick", "clonecraft.block.brick", Vector2(0, 4), mat1)
	man.quickUniformBlock(MODID, "clay", "clonecraft.block.clay", Vector2(1, 4), mat1, 1, 1, "tools:shovel")
	man.quickUniformBlock(MODID, "blockCoal", "clonecraft.block.coal_block", Vector2(2, 4), mat1)
	man.quickUniformBlock(MODID, "blockIron", "clonecraft.block.iron_block", Vector2(3, 4), mat1)
	man.quickUniformBlock(MODID, "blockGold", "clonecraft.block.gold_block", Vector2(4, 4), mat1)
	man.quickUniformBlock(MODID, "blockDiamond", "clonecraft.block.diamond_block", Vector2(5, 4), mat2, 3, 5, "tools:pickaxe", 2)
	man.quickUniformBlock(MODID, "blockEnerstone", "clonecraft.block.enerstone_crate", Vector2(0, 5), mat1)
	man.quickUniformBlock(MODID, "blockCopper", "clonecraft.block.copper_block", Vector2(1, 5), mat1)
	_makeItems()
