extends Node3D
class_name WorldControl


var _tool:VoxelToolTerrain
var _waitpos := Vector3.ZERO
var _waitrel := Vector3.ZERO
var waiting := false
var pausing := false
var tree:SceneTree
var _p:Player
var _terrain:VoxelTerrain


func raycheck(_rel:Vector3) -> bool:
    var col:KinematicCollision3D = _p.move_and_collide(_waitrel, true, 0.001, true)
    if col == null:
        return false
    return true


func waitForChunk() -> void:
    if _terrain.is_area_meshed(AABB(_waitpos, Vector3.ONE)):
        waiting = false


func startWait(pos:Vector3, rel:Vector3) -> void:
    waiting = true
    get_tree().paused = true
    _waitpos = pos
    _waitrel = rel


func pauseUnpause() -> void:
    if SettingManager.isIdle():
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            pausing = false
        else:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            $"/root/Node3D/VoxelTerrain".save_modified_blocks()
            pausing = true


func _input(event) -> void:
    if event.is_action_pressed("ui_cancel"):
        pauseUnpause()


func _ready() -> void:
    tree = get_tree()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _p = $player
    _terrain = BlockManager.terrain
    _tool = BlockManager._tool


func _process(_delta) -> void:
    if waiting:
        waitForChunk()
    tree.paused = pausing or waiting
    $Control/waitpanel.visible = waiting
    $Control/pausepanel.visible = pausing


func _on_setting_button_pressed():
    SettingManager.spawnMenu()
