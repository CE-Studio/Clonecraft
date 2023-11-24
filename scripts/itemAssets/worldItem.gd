extends RigidBody3D
class_name WorldItem


var despawnTime = 300
var iStack:ItemManager.ItemStack


var _point:Node3D
var _mesh:MeshInstance3D
var _timer:float = 0


func _ready() -> void:
    _point = $Node3D
    _mesh = $Node3D/Node3D


func setItem(itemStack:ItemManager.ItemStack) -> void:
    iStack = itemStack
    $Node3D/Node3D.mesh = itemStack.getMesh()


func _process(delta) -> void:
    _point.rotate_y(delta)
    _timer += delta
    _point.position.y = (sin(_timer) / 5) + 0.2

    if despawnTime > 0:
        if _timer > despawnTime:
            queue_free()
