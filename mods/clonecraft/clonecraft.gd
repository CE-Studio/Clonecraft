extends Mod

const MOD_ID = &"clonecraft"
var mat1:StandardMaterial3D = load("res://mods/clonecraft/baseBlocks.tres")
var mat2:StandardMaterial3D = load("res://mods/clonecraft/baseBlocksTransparent.tres")
var can_grass:Array[StringName] = []
var _item_texture:Texture2D = load("res://mods/clonecraft/items.png")
const _item_size:Vector2i = Vector2i(10, 10)

var grass_dirs := [
	[-1, 1],  [0, 1],  [1, 1],
	[-1, 0],           [1, 0],
	[-1, -1], [0, -1], [1, -1]
]


func _ready() -> void:
	pass


func run_grass(pos):
	grass_dirs.shuffle()
	for i in [1, 0, -1]:
		var rel_pos = (pos - Vector3i(grass_dirs[0][0], i, grass_dirs[0][1]))
		if man.get_block(rel_pos).full_id in can_grass:
			if man.get_block(rel_pos + Vector3i.UP).properties.has(&"air"):
				man.set_block(rel_pos, &"clonecraft:grassBlock", false, true, true)
	if not(man.get_block(pos + Vector3i.UP).properties.has(&"air")):
		man.set_block(pos, &"clonecraft:dirt", false, true, true)


func _make_gb() -> void:
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
			no_script,
			"tools:shovel",
			"plant",
			"plant",
			"plant"
	)
	bi.set_tickable(run_grass)
	bi.drop_item = &"clonecraft:dirt"
	man.end_block_register(bi)


func _make_ct() -> void:
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
			no_script,
			"tools:axe",
			"wood",
			"wood",
			"wood"
	)
	man.end_block_register(bi)


func _make_tnt() -> void:
	var model = man.start_block_register("clonecraft:tnt", Voxdat.vox.GEOMETRY_CUBE)
	model.set_mesh_collision_enabled(0, true)
	model.transparency_index = 0
	model.tile_left   = Vector2(1, 6)
	model.tile_right  = Vector2(1, 6)
	model.tile_bottom = Vector2(2, 6)
	model.tile_top    = Vector2(2, 6)
	model.tile_back   = Vector2(1, 6)
	model.tile_front  = Vector2(1, 6)
	model.set_material_override(0, mat1)
	var bi = BlockManager.BlockInfo.new(
			"clonecraft",
			"tnt",
			"clonecraft.block.tnt",
			model,
			1,
			1,
			false,
			false,
			no_script,
			"tools:axe",
			"grass",
			"grass",
			"grass"
	)
	man.end_block_register(bi)


func _make_ol() -> void:
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
			no_script,
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
			no_script,
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
			no_script,
			"tools:axe",
			"wood",
			"wood",
			"wood"
	)
	bi3.drop_item = &"clonecraft:logOak"
	man.end_block_register(bi3)


func _make_item(name:String, key:String, uv:Vector2i, needs_uid := false) -> ItemManager.Item:
	var new_item := ItemManager.register_item("clonecraft:" + name, "clonecraft.item." + key, ItemManager.ItemModel.make_2D(
		_item_texture,
		_item_size,
		uv
	))
	if needs_uid:
		new_item.static_meta = {
			"uid": generate_item_uid
		}
	return new_item


func _make_items() -> void:
	_make_item("stick", "stick", Vector2i(0, 0))
	_make_item("coal", "coal", Vector2i(1, 0))
	_make_item("ironIngot", "iron_ingot", Vector2i(2, 0))
	_make_item("copperIngot", "copper_ingot", Vector2i(3, 0))
	_make_item("enerstoneCrystal", "enerstone_crystal", Vector2i(4, 0))
	_make_item("goldIngot", "gold_ingot", Vector2i(5, 0))
	_make_item("brickItem", "brick", Vector2i(6, 0))
	_make_item("tntStick", "tnt_stick", Vector2i(7, 0))
	_make_item("diamond", "diamond", Vector2i(8, 0))
	_make_item("stonePickaxe", "stone_pickaxe", Vector2i(1, 1), true)
	_make_item("ironPickaxe", "iron_pickaxe", Vector2i(2, 1), true)
	_make_item("copperPickaxe", "copper_pickaxe", Vector2i(3, 1), true)
	_make_item("diamondPickaxe", "diamond_pickaxe", Vector2i(8, 1), true)
	_make_item("stoneAxe", "stone_axe", Vector2i(1, 2), true)
	_make_item("ironAxe", "iron_axe", Vector2i(2, 2), true)
	_make_item("copperAxe", "copper_axe", Vector2i(3, 2), true)
	_make_item("diamondAxe", "diamond_axe", Vector2i(8, 2), true)
	_make_item("stoneSword", "stone_sword", Vector2i(1, 3), true)
	_make_item("ironSword", "iron_sword", Vector2i(2, 3), true)
	_make_item("copperSword", "copper_sword", Vector2i(3, 3), true)
	_make_item("diamondSword", "diamond_sword", Vector2i(8, 3), true)
	var log_item := ItemManager.register_item(
		&"clonecraft:logOak",
		&"clonecraft.item.log_oak",
		# TODO make a way to generate block item models during the register phase
		# ...or just rework the phases
		ItemManager.ItemModel.make_3D(BoxMesh.new())
	)
	log_item.set_interaction_override(place_log)
	log_item.consume_on_interact = 1
	var chest_model:Mesh = load("res://mods/clonecraft/models/chest.obj")
	for i in chest_model.get_surface_count():
		chest_model.surface_set_material(i, load("res://mods/clonecraft/textures/chest.tres"))
	var chest_item := ItemManager.register_item(
		&"clonecraft:chest",
		&"clonecraft.item.chest",
		# TODO make a way to generate block item models during the register phase
		# ...or just rework the phases
		ItemManager.ItemModel.make_3D(chest_model)
	)
	chest_item.set_interaction_override(place_tile_entity.bind(&"clonecraft:chest"))
	chest_item.consume_on_interact = 1


func place_log(event:InputEvent) -> bool:
	if event.is_action_pressed("game_place"):
		if player.looking_at != null:
			var rel := player.looking_at.previous_position - player.looking_at.position
			var id := &"clonecraft:logVertOak"
			match rel.abs():
				Vector3i(1, 0, 0):
					id = &"clonecraft:logHoriz2Oak"
				Vector3i(0, 0, 1):
					id = &"clonecraft:logHoriz1Oak"
				_:
					pass
			return man.set_block(player.looking_at.previous_position, id)
	return false


func place_tile_entity(event:InputEvent, id:StringName, meta := {}) -> bool:
	if not meta.has("facing"):
		meta["facing"] = (int(round(player.head.rotation_degrees.y / 90)) + 2) % 4
	if event.is_action_pressed("game_place"):
		if player.abilities.allowBuild and (player.looking_at != null):
			return BlockEntityManager.instance.place(id, player.looking_at.previous_position, meta)
	return false


func block_fall(pos:Vector3) -> void:
	if man.get_block(pos + Vector3.DOWN).properties.has(&"air"):
		WorldControl.instance.spawn_falling_block(pos)


func register_phase() -> void:
	Translator.load_from_json("res://mods/clonecraft/lang/en_us.json")
	CMDprocessor.register_command(load("res://mods/clonecraft/cmd/give.gd").new())
	CMDprocessor.register_command(load("res://mods/clonecraft/cmd/editBar.gd").new())
	CMDprocessor.register_command(load("res://mods/clonecraft/cmd/tp.gd").new())
	man.quick_uniform_block(MOD_ID, "stone", "clonecraft.block.stone", Vector2(0, 0), mat1).drop_item = &"clonecraft:cobblestone"
	man.quick_uniform_block(MOD_ID, "dirt", "clonecraft.block.dirt", Vector2(1, 0), mat1, 1, 1, "tools:shovel")
	can_grass.append("clonecraft:dirt")
	_make_gb()
	man.quick_uniform_block(MOD_ID, "cobblestone", "clonecraft.block.cobblestone", Vector2(4, 0), mat1)
	man.quick_uniform_block(MOD_ID, "oreCoal", "clonecraft.block.coal_ore", Vector2(5, 0), mat1)
	man.quick_uniform_block(MOD_ID, "oreIron", "clonecraft.block.iron_ore", Vector2(0, 1), mat1)
	man.quick_uniform_block(MOD_ID, "oreGold", "clonecraft.block.gold_ore", Vector2(1, 1), mat1)
	man.quick_uniform_block(MOD_ID, "oreDiamond", "clonecraft.block.diamond_ore", Vector2(2, 1), mat1).drop_item = &"clonecraft:diamond"
	man.quick_uniform_block(MOD_ID, "oreEnerstone", "clonecraft.block.enerstone_ore", Vector2(3, 1), mat1)
	man.quick_uniform_block(MOD_ID, "oreCopper", "clonecraft.block.copper_ore", Vector2(4, 1), mat1)
	man.quick_uniform_block(MOD_ID, "tileStone", "clonecraft.block.stone_tile", Vector2(5, 1), mat1)
	man.quick_uniform_block(MOD_ID, "brickStone", "clonecraft.block.stone_bricks", Vector2(0, 2), mat1)
	man.quick_uniform_block(MOD_ID, "plankOak", "clonecraft.block.oak_planks", Vector2(1, 2), mat1, 3, 6, "tools:axe")
	man.quick_uniform_block(MOD_ID, "tileOak", "clonecraft.block.oak_plank_tile", Vector2(2, 2), mat1, 3, 6, "tools:axe")
	_make_ct()
	_make_ol()
	man.quick_uniform_block(MOD_ID, "barkOak", "clonecraft.block.oak_bark", Vector2(5, 2), mat1, 3, 6, "tools:axe")
	man.quick_uniform_block(MOD_ID, "knotOak", "clonecraft.block.oak_knot", Vector2(1, 3), mat1, 3, 6, "tools:axe")
	man.quick_uniform_block(MOD_ID, "leavesOak", "clonecraft.block.oak_leaves", Vector2(2, 3), mat2, 1, 1, "tools:shears", 1)
	man.quick_uniform_block(MOD_ID, "gravel", "clonecraft.block.gravel", Vector2(3, 3), mat1, 1, 1, "tools:shovel").set_scripted(block_fall)
	man.quick_uniform_block(MOD_ID, "sand", "clonecraft.block.sand", Vector2(4, 3), mat1, 1, 1, "tools:shovel").set_scripted(block_fall)
	man.quick_uniform_block(MOD_ID, "glass", "clonecraft.block.glass", Vector2(5, 3), mat2, 1, 1, "tools:pickaxe", 2)
	man.quick_uniform_block(MOD_ID, "brick", "clonecraft.block.brick", Vector2(0, 4), mat1)
	man.quick_uniform_block(MOD_ID, "clay", "clonecraft.block.clay", Vector2(1, 4), mat1, 1, 1, "tools:shovel")
	man.quick_uniform_block(MOD_ID, "blockCoal", "clonecraft.block.coal_block", Vector2(2, 4), mat1)
	man.quick_uniform_block(MOD_ID, "blockIron", "clonecraft.block.iron_block", Vector2(3, 4), mat1)
	man.quick_uniform_block(MOD_ID, "blockGold", "clonecraft.block.gold_block", Vector2(4, 4), mat1)
	man.quick_uniform_block(MOD_ID, "blockDiamond", "clonecraft.block.diamond_block", Vector2(5, 4), mat2, 3, 5, "tools:pickaxe", 2)
	man.quick_uniform_block(MOD_ID, "blockEnerstone", "clonecraft.block.enerstone_crate", Vector2(0, 5), mat1)
	man.quick_uniform_block(MOD_ID, "blockCopper", "clonecraft.block.copper_block", Vector2(1, 5), mat1)
	_make_tnt()
	
	BlockEntityManager.te_list[&"clonecraft:chest"] = load("res://mods/clonecraft/tileEntities/chest.tscn")
	_make_items()
