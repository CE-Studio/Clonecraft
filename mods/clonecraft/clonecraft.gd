extends Mod

const MODID = &"clonecraft"
var mat1 = load("res://mods/clonecraft/baseblocks.tres")
var mat2 = load("res://mods/clonecraft/baseblocksTransparent.tres")
var canGrass = []
var _it:Texture2D = load("res://mods/clonecraft/items.png")
const _is:Vector2i = Vector2i(10, 10)

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
		if man.get_block(rpos).full_id in canGrass:
			if man.get_block(rpos + Vector3i.UP).properties.has(&"air"):
				man.set_block(rpos, &"clonecraft:grassBlock", false, true, true)
	if not(man.get_block(pos + Vector3i.UP).properties.has(&"air")):
		man.set_block(pos, &"clonecraft:dirt", false, true, true)


func _makeGB() -> void:
	var model = man.start_block_register("clonecraft:grassBlock", Voxdat.vox.GEOMETRY_CUBE)
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
	bi.set_tickable(runGrass)
	bi.drop_item = &"clonecraft:dirt"
	man.end_block_register(bi)


func _makeCT() -> void:
	var model = man.start_block_register("clonecraft:craftingBench", Voxdat.vox.GEOMETRY_CUBE)
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
	man.end_block_register(bi)


func _makeOL() -> void:
	var model1 = man.start_block_register("clonecraft:logVertOak", Voxdat.vox.GEOMETRY_CUBE)
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
	bi1.drop_item = &"clonecraft:logOak"
	man.end_block_register(bi1)

	var model2 = man.start_block_register(&"clonecraft:logHoriz1Oak", Voxdat.vox.GEOMETRY_CUBE)
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
			"logHoriz1Oak",
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
	bi2.drop_item = &"clonecraft:logOak"
	man.end_block_register(bi2)

	var model3 = man.start_block_register(&"clonecraft:logHoriz2Oak", Voxdat.vox.GEOMETRY_CUBE)
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
			"logHoriz2Oak",
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
	bi3.drop_item = &"clonecraft:logOak"
	man.end_block_register(bi3)


func _mitem(name:String, key:String, uv:Vector2i, needs_uid := false) -> ItemManager.Item:
	var nitem := ItemManager.registerItem("clonecraft:" + name, "clonecraft.item." + key, ItemManager.ItemModel.make2D(
		_it,
		_is,
		uv
	))
	if needs_uid:
		nitem.static_meta = {
			"udi": generate_item_uid
		}
	return nitem


func _makeItems() -> void:
	_mitem("stick", "stick", Vector2i(0, 0))
	_mitem("coal", "coal", Vector2i(1, 0))
	_mitem("ironIngot", "iron_ingot", Vector2i(2, 0))
	_mitem("copperIngot", "copper_ingot", Vector2i(3, 0))
	_mitem("enerstoneCrystal", "enerstone_crystal", Vector2i(4, 0))
	_mitem("goldIngot", "gold_ingot", Vector2i(5, 0))
	_mitem("brickItem", "brick", Vector2i(6, 0))
	_mitem("tntStick", "tnt_stick", Vector2i(7, 0))
	_mitem("diamond", "diamond", Vector2i(8, 0))
	_mitem("stonePickaxe", "stone_pickaxe", Vector2i(1, 1), true)
	_mitem("ironPickaxe", "iron_pickaxe", Vector2i(2, 1), true)
	_mitem("copperPickaxe", "copper_pickaxe", Vector2i(3, 1), true)
	_mitem("diamondPickaxe", "diamond_pickaxe", Vector2i(8, 1), true)
	_mitem("stoneAxe", "stone_axe", Vector2i(1, 2), true)
	_mitem("ironAxe", "iron_axe", Vector2i(2, 2), true)
	_mitem("copperAxe", "copper_axe", Vector2i(3, 2), true)
	_mitem("diamondAxe", "diamond_axe", Vector2i(8, 2), true)
	_mitem("stoneSword", "stone_sword", Vector2i(1, 3), true)
	_mitem("ironSword", "iron_sword", Vector2i(2, 3), true)
	_mitem("copperSword", "copper_sword", Vector2i(3, 3), true)
	_mitem("diamondSword", "diamond_sword", Vector2i(8, 3), true)
	var logitem := ItemManager.registerItem(
		&"clonecraft:logOak",
		&"clonecraft.item.log_oak",
		# TODO make a way to gereate block item models during the register phasse
		# ...or just rework the phases
		ItemManager.ItemModel.make3D(BoxMesh.new())
	)
	logitem.setInteractionOverride(placelog)
	logitem.consumeOnInteract = 1
	var chestmodel:Mesh = preload("res://mods/clonecraft/models/chest.obj")
	for i in chestmodel.get_surface_count():
		chestmodel.surface_set_material(i, preload("res://mods/clonecraft/textures/chest.tres"))
	var chestitem := ItemManager.registerItem(
		&"clonecraft:chest",
		&"clonecraft.item.chest",
		# TODO make a way to gereate block item models during the register phasse
		# ...or just rework the phases
		ItemManager.ItemModel.make3D(chestmodel)
	)
	chestitem.setInteractionOverride(placete.bind(&"clonecraft:chest"))
	chestitem.consumeOnInteract = 1
	#ItemManager.registerItem(
	#	&"clonecraft:dbtile",
	#	&"clonecraft.item.dbtile",
	#	ItemManager.ItemModel.make2D(_it, _is, Vector2i(7, 0))
	#).setInteractionOverride(placete.bind(&"null:null"))


func placelog(event:InputEvent) -> bool:
	if event.is_action_pressed("game_place"):
		if player.lookingAt != null:
			var rel := player.lookingAt.previous_position - player.lookingAt.position
			var id := &"clonecraft:logVertOak"
			match rel.abs():
				Vector3i(1, 0, 0):
					id = &"clonecraft:logHoriz2Oak"
				Vector3i(0, 0, 1):
					id = &"clonecraft:logHoriz1Oak"
				_:
					pass
			return man.set_block(player.lookingAt.previous_position, id)
	return false


func placete(event:InputEvent, id:StringName, meta := {}) -> bool:
	if not meta.has("facing"):
		meta["facing"] = (int(round(player.head.rotation_degrees.y / 90)) + 2) % 4
	if event.is_action_pressed("game_place"):
		if player.abilities.allowBuild and (player.lookingAt != null):
			return BlockEntityManager.instance.place(id, player.lookingAt.previous_position, meta)
	return false


func blockFall(pos:Vector3) -> void:
	if man.get_block(pos + Vector3.DOWN).properties.has(&"air"):
		WorldControl.instance.spawnFallingBlock(pos)


func register_phase() -> void:
	Translator.loadFromJson("res://mods/clonecraft/lang/en_us.json")
	CMDprocessor.registerCommand(load("res://mods/clonecraft/cmd/give.gd").new())
	CMDprocessor.registerCommand(load("res://mods/clonecraft/cmd/editbar.gd").new())
	CMDprocessor.registerCommand(load("res://mods/clonecraft/cmd/tp.gd").new())
	man.quick_uniform_block(MODID, "stone", "clonecraft.block.stone", Vector2(0, 0), mat1).drop_item = &"clonecraft:cobblestone"
	man.quick_uniform_block(MODID, "dirt", "clonecraft.block.dirt", Vector2(1, 0), mat1, 1, 1, "tools:shovel")
	canGrass.append("clonecraft:dirt")
	_makeGB()
	man.quick_uniform_block(MODID, "cobblestone", "clonecraft.block.cobblestone", Vector2(4, 0), mat1)
	man.quick_uniform_block(MODID, "oreCoal", "clonecraft.block.coal_ore", Vector2(5, 0), mat1)
	man.quick_uniform_block(MODID, "oreIron", "clonecraft.block.iron_ore", Vector2(0, 1), mat1)
	man.quick_uniform_block(MODID, "oreGold", "clonecraft.block.gold_ore", Vector2(1, 1), mat1)
	man.quick_uniform_block(MODID, "oreDiamond", "clonecraft.block.diamond_ore", Vector2(2, 1), mat1).drop_item = &"clonecraft:diamond"
	man.quick_uniform_block(MODID, "oreEnerstone", "clonecraft.block.enerstone_ore", Vector2(3, 1), mat1)
	man.quick_uniform_block(MODID, "oreCopper", "clonecraft.block.copper_ore", Vector2(4, 1), mat1)
	man.quick_uniform_block(MODID, "tileStone", "clonecraft.block.stone_tile", Vector2(5, 1), mat1)
	man.quick_uniform_block(MODID, "brickStone", "clonecraft.block.stone_bricks", Vector2(0, 2), mat1)
	man.quick_uniform_block(MODID, "plankOak", "clonecraft.block.oak_planks", Vector2(1, 2), mat1, 3, 6, "tools:axe")
	man.quick_uniform_block(MODID, "tileOak", "clonecraft.block.oak_plank_tile", Vector2(2, 2), mat1, 3, 6, "tools:axe")
	_makeCT()
	_makeOL()
	man.quick_uniform_block(MODID, "barkOak", "clonecraft.block.oak_bark", Vector2(5, 2), mat1, 3, 6, "tools:axe")
	man.quick_uniform_block(MODID, "knotOak", "clonecraft.block.oak_knot", Vector2(1, 3), mat1, 3, 6, "tools:axe")
	man.quick_uniform_block(MODID, "leavesOak", "clonecraft.block.oak_leaves", Vector2(2, 3), mat2, 1, 1, "tools:shears", 1)
	man.quick_uniform_block(MODID, "gravel", "clonecraft.block.gravel", Vector2(3, 3), mat1, 1, 1, "tools:shovel").set_scripted(blockFall)
	man.quick_uniform_block(MODID, "sand", "clonecraft.block.sand", Vector2(4, 3), mat1, 1, 1, "tools:shovel").set_scripted(blockFall)
	man.quick_uniform_block(MODID, "glass", "clonecraft.block.glass", Vector2(5, 3), mat2, 1, 1, "tools:pickaxe", 2)
	man.quick_uniform_block(MODID, "brick", "clonecraft.block.brick", Vector2(0, 4), mat1)
	man.quick_uniform_block(MODID, "clay", "clonecraft.block.clay", Vector2(1, 4), mat1, 1, 1, "tools:shovel")
	man.quick_uniform_block(MODID, "blockCoal", "clonecraft.block.coal_block", Vector2(2, 4), mat1)
	man.quick_uniform_block(MODID, "blockIron", "clonecraft.block.iron_block", Vector2(3, 4), mat1)
	man.quick_uniform_block(MODID, "blockGold", "clonecraft.block.gold_block", Vector2(4, 4), mat1)
	man.quick_uniform_block(MODID, "blockDiamond", "clonecraft.block.diamond_block", Vector2(5, 4), mat2, 3, 5, "tools:pickaxe", 2)
	man.quick_uniform_block(MODID, "blockEnerstone", "clonecraft.block.enerstone_crate", Vector2(0, 5), mat1)
	man.quick_uniform_block(MODID, "blockCopper", "clonecraft.block.copper_block", Vector2(1, 5), mat1)
	BlockEntityManager.te_list[&"clonecraft:chest"] = preload("res://mods/clonecraft/tileEntities/chest.tscn")
	_makeItems()
