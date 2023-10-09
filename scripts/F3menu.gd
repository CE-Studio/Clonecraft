extends Label

const LABEL1_TEXT := (
    "Clonecraft %s" +
    "\nFPS: %s" +
    "\nX/Y/Z: %s, %s, %s" +
    "\nRotation: %s, %s" +
    "\nLooking at: %s, %s, %s: %s"
)
const LABEL2_TEXT := (
    "%s %s"
)


var gpuinfo := ["Unkown Driver", "0.0.0"]


@onready var player:Player = $"/root/Node3D/player"
@onready var head:Node3D = player.get_child(1)
@onready var cam:Camera3D = head.get_child(0)
@onready var other:Label = $"../f32"


func _ready():
    var h = OS.get_video_adapter_driver_info()
    if h.size() >= 2:
        if h[0] != "":
            gpuinfo = h


func _process(_delta):
    var pl = Vector3i.ZERO
    var v = "None"
    if player.lookingAt != null:
        pl = player.lookingAt.get_position()
        v = BlockManager.blockList[player.voxelTool.get_voxel(pl)].fullID
    text = LABEL1_TEXT % [
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
    other.text = LABEL2_TEXT % [
        gpuinfo[0], gpuinfo[1],
    ]
