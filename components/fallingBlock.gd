extends RigidBody3D
class_name FallingBlock


var ID:StringName


func _ready() -> void:
	var v = BlockManager.get_block(position)
	ID = v.full_id
	BlockManager.set_block(position.floor(), &"clonecraft:air", false, true, true)
	$meshInstance3d.mesh = ItemManager.items[ID].model.mesh


func _physics_process(delta: float) -> void:
	if not BlockManager.get_block((position.floor()) + (Vector3.DOWN / 1.8)).properties.has(&"air"):
		if not BlockManager.set_block(position.floor(), ID):
			ItemManager.spawn_world_item(ItemManager.ItemStack.new(ID, 1), position)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is VoxelTerrain and not BlockManager.get_block((position.floor()) + Vector3.DOWN).properties.has(&"air"):
		if not BlockManager.set_block(position.floor(), ID):
			ItemManager.spawn_world_item(ItemManager.ItemStack.new(ID, 1), position)
		queue_free()
