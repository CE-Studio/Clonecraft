extends Mod


# Set to yor mod's ID
const MODID:StringName = "mobs"


var isprite0:Texture2D = load("res://mods/mobs/textures/item/items0.png")


# Mod initialization code goes here
func registerPhase() -> void:
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
	)
