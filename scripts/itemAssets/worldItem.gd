extends RigidBody3D
class_name WorldItem


@export var pickupTime:int = 3
var despawnTime = 300
var iStack:ItemManager.ItemStack


@onready var _point:Node3D = $Node3D
@onready var _mesh:MeshInstance3D = $Node3D/Node3D
@onready var _sprite:Sprite3D = $Node3D/sprite3d
var _timer:float = 0


var newpos = null


func setItem(itemStack:ItemManager.ItemStack) -> void:
	iStack = itemStack
	var m := itemStack.getModel()
	if m.is3D:
		$Node3D/Node3D.mesh = m.mesh
	else:
		$Node3D/sprite3d.texture = m.texture
		$Node3D/sprite3d.hframes = m.atlasSize.x
		$Node3D/sprite3d.vframes = m.atlasSize.y
		$Node3D/sprite3d.frame_coords = m.frame
	if iStack.count != 1:
		$Node3D/sprite3d/label3d.text = str(iStack.count)
	$Node3D/sprite3d/label3d.visible = ProjectSettings.get_setting("gameplay/ui/show_item_count")


func canPickup() -> bool:
	return pickupTime <= _timer


func _process(delta) -> void:
	_point.rotate_y(delta)
	_timer += delta
	_point.position.y = (sin(_timer) / 5) + 0.2
	_sprite.look_at(WorldControl.instance._p.global_position, Vector3.UP, true)

	if despawnTime > 0:
		if _timer > despawnTime:
			queue_free()


func _physics_process(delta: float) -> void:
	var pos := Vector3i(global_position.floor())
	if not BlockManager.getBlock(pos).properties.has(BlockManager.BlockInfo.INCOMPLETE_HITBOX):
		tryMove(pos, delta)
	
	
func tryMove(pos:Vector3i, delta:float) -> void:
	for y in [1, 0, -1, 2, -2]:
		for x in [0, 1, -1, 2, -2]:
			for z in [0, 1, -1, 2, -2]:
				var rel := Vector3i(x, y, z)
				if BlockManager.getBlock(pos + rel).properties.has(BlockManager.BlockInfo.INCOMPLETE_HITBOX):
					newpos = global_position + Vector3(rel)
					return
	newpos = global_position + Vector3(0, 0.5 * delta, 0)
	
	
func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	if newpos != null:
		state.linear_velocity = Vector3.ZERO
		var t := state.get_transform()
		t.origin = newpos
		global_position = newpos
		state.transform = t
		newpos = null
