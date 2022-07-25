extends Label

const labeltext = "FPS: %s\nX/Y/Z: %s, %s, %s\nRotation: %s, %s\nLooking at: %s, %s, %s: %s"
var player
var head
var cam
var bm

# Called when the node enters the scene tree for the first time.
func _ready():
    player = $"/root/Node3D/player"
    bm = $"/root/BlockManager"
    head = player.get_child(1)
    cam = head.get_child(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var pl = Vector3i.ZERO
    var v = "None"
    if player.lookingAt != null:
        pl = player.lookingAt.get_position()
        v = bm.blockList[player.vt.get_voxel(pl)].fullID
    text = labeltext % [Engine.get_frames_per_second(),
                        snapped(player.position.x, 0.01),
                        snapped(player.position.y, 0.01),
                        snapped(player.position.z, 0.01),
                        snapped(rad2deg(cam.rotation.x), 0.01),
                        snapped(rad2deg(head.rotation.y), 0.01),
                        pl[0],
                        pl[1],
                        pl[2],
                        v]
