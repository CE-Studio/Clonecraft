extends RigidBody3D
class_name WorldItem


@export var pickup_time:int = 3
var despawn_time = 300
var i_stack:ItemManager.ItemStack


@onready var _point:Node3D = $Node3D
@onready var _mesh:MeshInstance3D = $Node3D/Node3D
@onready var _sprite:Sprite3D = $Node3D/sprite3d
var _timer:float = 0


var new_pos = null


func set_item(item_stack:ItemManager.ItemStack) -> void:
	i_stack = item_stack
	var m := item_stack.get_model()
	if m.is_3D:
		$Node3D/Node3D.mesh = m.mesh
	else:
		$Node3D/sprite3d.texture = m.texture
		$Node3D/sprite3d.hframes = m.atlas_size.x
		$Node3D/sprite3d.vframes = m.atlas_size.y
		$Node3D/sprite3d.frame_coords = m.frame
	if i_stack.count != 1:
		$Node3D/sprite3d/label3d.text = str(i_stack.count)
	$Node3D/sprite3d/label3d.visible = ProjectSettings.get_setting("gameplay/ui/show_item_count")


func can_pickup() -> bool:
	return pickup_time <= _timer


func _process(delta) -> void:
	_point.rotate_y(delta)
	_timer += delta
	_point.position.y = (sin(_timer) / 5) + 0.2
	_sprite.look_at(WorldControl.instance._player.global_position, Vector3.UP, true)

	if despawn_time > 0:
		if _timer > despawn_time:
			queue_free()


func _physics_process(delta: float) -> void:
	var pos := Vector3i(global_position.floor())
	if not BlockManager.get_block(pos).properties.has(BlockManager.BlockInfo.INCOMPLETE_HITBOX):
		try_move(pos, delta)
	
	
func try_move(pos:Vector3i, delta:float) -> void:
	for y in [1, 0, -1, 2, -2]:
		for x in [0, 1, -1, 2, -2]:
			for z in [0, 1, -1, 2, -2]:
				var rel := Vector3i(x, y, z)
				if BlockManager.get_block(pos + rel).properties.has(BlockManager.BlockInfo.INCOMPLETE_HITBOX):
					new_pos = global_position + Vector3(rel)
					return
	new_pos = global_position + Vector3(0, 0.5 * delta, 0)
	
	
func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	if new_pos != null:
		state.linear_velocity = Vector3.ZERO
		var t := state.get_transform()
		t.origin = new_pos
		global_position = new_pos
		state.transform = t
		new_pos = null
