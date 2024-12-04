extends RigidBody3D
class_name WorldItem


@export var pickupTime:int = 3
var despawnTime = 300
var iStack:ItemManager.ItemStack


@onready var _point:Node3D = $Node3D
@onready var _mesh:MeshInstance3D = $Node3D/Node3D
@onready var _sprite:Sprite3D = $Node3D/sprite3d
var _timer:float = 0


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
