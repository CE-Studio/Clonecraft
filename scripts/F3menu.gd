extends Label

const LABEL1_TEXT := (
"Clonecraft %s
FPS: %s
X/Y/Z: %s, %s, %s
Rotation: %s, %s
Facing: %s
Looking at: %s, %s, %s: %s
Draw calls: %s"
)
const LABEL2_TEXT := (
	"%s %s"
)


var gpu_info := ["Unknown Driver", "0.0.0"]


@onready var player:Player = $"/root/Node3D/player"
@onready var head:Node3D = player.get_child(1)
@onready var cam:Camera3D = head.get_child(0)
@onready var other:Label = $"../f32"


func _ready() -> void:
	var h = OS.get_video_adapter_driver_info()
	if h.size() >= 2:
		if h[0] != "":
			gpu_info = h


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_showdebug"):
		if visible:
			hide()
			other.hide()
		else:
			show()
			other.show()


func _process(_delta) -> void:
	if not is_visible_in_tree():
		return
	var pl := Vector3i.ZERO
	var v := "None"
	var dc := int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	if player.looking_at != null:
		pl = player.looking_at.get_position()
		v = BlockManager.block_list[player.voxel_tool.get_voxel(pl)].full_id
	text = LABEL1_TEXT % [
		SettingManager.VERSION,
		Engine.get_frames_per_second(),
		snapped(player.position.x, 0.01),
		snapped(player.position.y, 0.01),
		snapped(player.position.z, 0.01),
		snapped(cam.rotation_degrees.x, 0.01),
		snapped(head.rotation_degrees.y, 0.01),
		(int(round(head.rotation_degrees.y / 90)) + 2) % 4,
		pl[0],
		pl[1],
		pl[2],
		v,
		dc,
	]
	other.text = LABEL2_TEXT % [
		gpu_info[0], gpu_info[1],
	]
