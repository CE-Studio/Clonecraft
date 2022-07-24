extends Label

const labeltext = "FPS: %s\nX/Y/Z: %s, %s, %s\nRotation: %s, %s"
var player
var head
var cam

# Called when the node enters the scene tree for the first time.
func _ready():
    player = $/root/Node3D/player
    head = player.get_child(1)
    cam = head.get_child(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    text = labeltext % [Engine.get_frames_per_second(),
                        snapped(player.position.x, 0.01),
                        snapped(player.position.y, 0.01),
                        snapped(player.position.z, 0.01),
                        snapped(rad2deg(cam.rotation.x), 0.01),
                        snapped(rad2deg(head.rotation.y), 0.01)]
