extends Label

const LABEL_TEXT := (
    "Clonecraft %s" +
    "\nFPS: %s" +
    "\nX/Y/Z: %s, %s, %s" +
    "\nRotation: %s, %s" +
    "\nLooking at: %s, %s, %s: %s"
)
var player:Player
var head:Node3D
var cam:Camera3D


func _ready():
    player = $"/root/Node3D/player"
    head = player.get_child(1)
    cam = head.get_child(0)


func _process(_delta):
    var pl = Vector3i.ZERO
    var v = "None"
    if player.lookingAt != null:
        pl = player.lookingAt.get_position()
        v = BlockManager.blockList[player.voxelTool.get_voxel(pl)].fullID
    text = LABEL_TEXT % [
        SettingManager.VERSION,
        Engine.get_frames_per_second(),
        snapped(player.position.x, 0.01),
        snapped(player.position.y, 0.01),
        snapped(player.position.z, 0.01),
        snapped(rad_to_deg(cam.rotation.x), 0.01),
        snapped(rad_to_deg(head.rotation.y), 0.01),
        pl[0],
        pl[1],
        pl[2],
        v,
    ]
