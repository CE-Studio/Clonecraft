extends RigidBody3D
class_name FallingBlock


var ID:StringName


func _ready() -> void:
	var v = BlockManager.getBlock(position)
	ID = v.fullID
	BlockManager.setBlock(position.floor(), &"clonecraft:air", false, true, true)
	$meshInstance3d.mesh = ItemManager.items[ID].model


func _physics_process(delta: float) -> void:
	if not BlockManager.getBlock((position.floor()) + (Vector3.DOWN / 1.8)).properties.has(&"air"):
		if not BlockManager.setBlock(position.floor(), ID):
			ItemManager.spawnWorldItem(ItemManager.ItemStack.new(ID, 1), position)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is VoxelTerrain and not BlockManager.getBlock((position.floor()) + Vector3.DOWN).properties.has(&"air"):
		if not BlockManager.setBlock(position.floor(), ID):
			ItemManager.spawnWorldItem(ItemManager.ItemStack.new(ID, 1), position)
		queue_free()
