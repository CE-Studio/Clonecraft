extends Mod


# Set to yor mod's ID
const MOD_ID:StringName = "mobs"


var item_sprite_sheet_0:Texture2D = load("res://mods/mobs/textures/item/items0.png")


var mobs:Dictionary[StringName, PackedScene] = {
	&"mobs:blastMiner": preload("res://mods/mobs/hostile/machine/Blastminer.tscn")
}


func use_spawn_item(event:InputEvent, id:StringName) -> bool:
	print(event)
	if player.looking_at != null:
		if event.is_action_pressed("game_place"):
			if mobs.has(id):
				var new_mob:Node3D = mobs[id].instantiate()
				EntityManager.instance.add_child(new_mob)
				new_mob.global_position = Vector3(player.looking_at.previous_position) + Vector3(0.5, 0.5, 0.5)
				return true
	return false


# Mod initialization code goes here
func register_phase() -> void:
	Translator.load_from_json("res://mods/mobs/lang/en_us.json")
	ItemManager.register_item(
		"mobs:cog",
		"mobs.item.cog",
		ItemManager.ItemModel.make_2D(
			item_sprite_sheet_0,
			Vector2i(10, 10),
			Vector2i(0, 0),
		)
	)
	ItemManager.register_item(
		"mobs:spawnBlastMiner",
		"mobs.spawn_item.blast_miner",
		ItemManager.ItemModel.make_2D(
			item_sprite_sheet_0,
			Vector2i(10, 10),
			Vector2i(1, 0),
		)
	).set_interaction_override(use_spawn_item.bind(&"mobs:blastMiner")).consume_on_interact = 1
