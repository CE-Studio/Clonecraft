extends Mod


# Set to yor mod's ID
const MODID:StringName = "mobs"


var isprite0:Texture2D = load("res://mods/mobs/textures/item/items0.png")


var mobs:Dictionary[StringName, PackedScene] = {
	&"mobs:blastMiner": preload("res://mods/mobs/hostile/machine/Blastminer.tscn")
}


func useSpawnItem(event:InputEvent, id:StringName) -> bool:
	print(event)
	if player.lookingAt != null:
		if event.is_action_pressed("game_place"):
			if mobs.has(id):
				var newmob:Node3D = mobs[id].instantiate()
				EntityManager.instance.add_child(newmob)
				newmob.global_position = Vector3(player.lookingAt.previous_position) + Vector3(0.5, 0.5, 0.5)
				return true
	return false


# Mod initialization code goes here
func register_phase() -> void:
	Translator.loadFromJson("res://mods/mobs/lang/en_us.json")
	ItemManager.registerItem(
		"mobs:cog",
		"mobs.item.cog",
		ItemManager.ItemModel.make2D(
			isprite0,
			Vector2i(10, 10),
			Vector2i(0, 0),
		)
	)
	ItemManager.registerItem(
		"mobs:spawnBlastMiner",
		"mobs.spawn_item.blast_miner",
		ItemManager.ItemModel.make2D(
			isprite0,
			Vector2i(10, 10),
			Vector2i(1, 0),
		)
	).setInteractionOverride(useSpawnItem.bind(&"mobs:blastMiner")).consumeOnInteract = 1
