extends Node

var man:blockManager
var tlabel:Label
var bid:int
var terrain:VoxelTerrain
var tool:VoxelTool
var player

func refman(ref):
    man = ref
    terrain = man.get_node("/root/Node3D/VoxelTerrain")
    player = man.get_node("/root/Node3D/player")
    tool = terrain.get_voxel_tool()

func input(event):
    if event is InputEventMouseButton:
        if (event.button_index == 4) && (event.pressed):
            bid -= 1
            if bid < 0:
                bid += man.blockList.size()
            tlabel.text = man.blockList[bid].fullID
        elif (event.button_index == 5) && (event.pressed):
            bid += 1
            if bid >= man.blockList.size():
                bid -= man.blockList.size()
            tlabel.text = man.blockList[bid].fullID
        elif (event.button_index == 2) && (event.pressed):
            if player.lookingAt != null:
                tool.set_voxel(player.lookingAt.previous_position, bid)
        elif (event.button_index == 1) && (event.pressed):
            if player.lookingAt != null:
                tool.set_voxel(player.lookingAt.position, 0)

func registerPhase():
    tlabel = Label.new()
    tlabel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    tlabel.position.y -= 20
    tlabel.text = man.blockList[bid].fullID
    man.get_node("/root/Node3D/Control").add_child(tlabel)
    man.inputRegister(Callable(self, "input"))
