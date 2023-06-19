extends Node3D
class_name WorldControl


var _tool:VoxelToolTerrain
var _waitpos := Vector3.ZERO
var _waitrel := Vector3.ZERO
var waiting := false
var pausing := false
var tree:SceneTree


func raycheck(rel:Vector3) -> bool:
    var p:Player = $player
    var col:KinematicCollision3D = p.move_and_collide(_waitrel, true, 0.001, true)
    if col == null:
        return false
    return true


func waitForChunk():
    if _tool.is_area_editable(AABB(_waitpos, Vector3.ONE)):
        var h := BlockManager.getBlock(_waitpos)
        if h.properties.has(&"incompleteHitbox"):
            waiting = false
        elif raycheck(_waitrel):
            waiting = false
        else:
            var p:Player = $player
            if not BlockManager.getBlock(p.position).properties.has(&"incompleteHitbox"):
                p.position += Vector3.UP
            elif not BlockManager.getBlock(p.position + Vector3.UP).properties.has(&"incompleteHitbox"):
                p.position += Vector3.UP
            elif not BlockManager.getBlock(p.position + Vector3.DOWN).properties.has(&"incompleteHitbox"):
                p.position += Vector3.UP
                

func startWait(pos:Vector3, rel:Vector3):
    waiting = true
    get_tree().paused = true
    _waitpos = pos
    _waitrel = rel


func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            pausing = false
        else:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            $"/root/Node3D/VoxelTerrain".save_modified_blocks()
            pausing = true


func _ready():
    tree = get_tree()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    $Control/waitpanel/CenterContainer/Label.text = Translator.translate(&"gui.chunkloading.wait")


func _process(delta):
    if waiting:
        waitForChunk()
    tree.paused = pausing or waiting
    $Control/waitpanel.visible = waiting
    $Control/pausepanel.visible = pausing
