extends Mod

var tlabel:Label
var bid:int : set = _bidSet
var itemDisp:MeshInstance3D

func _bidSet(val:int):
    bid = val
    if bid < 0:
        bid += man.blockList.size()
    elif bid >= man.blockList.size():
        bid -= man.blockList.size()
    tlabel.text = man.blockList[bid].fullID
    itemDisp.mesh = ItemManager.items[man.blockList[bid].fullID].model


func input(event):
    if event is InputEventMouseButton:
        if (event.button_index == 4) && (event.pressed):
            self.bid -= 1
        elif (event.button_index == 5) && (event.pressed):
            self.bid += 1
        elif (event.button_index == 2) && (event.pressed):
            if player.lookingAt != null:
                tool.set_voxel(player.lookingAt.previous_position, bid)
        elif (event.button_index == 1) && (event.pressed):
            if player.lookingAt != null:
                tool.set_voxel(player.lookingAt.position, 0)
        elif (event.button_index == 3) && (event.pressed):
            if player.lookingAt != null:
                var pl := player.lookingAt.position
                self.bid = player.voxelTool.get_voxel(pl)
                man.log("debugtools", "Block " + str(bid))
    elif event is InputEventKey:
        if event.pressed:
            if event.as_text_keycode() == "Q":
                ItemManager.spawnWorldItem(ItemManager.ItemStack.new(man.blockList[bid].fullID, 1), player.position)


func update(delta):
    var ssize := ItemManager.screenSize / 60
    itemDisp.position = Vector3(-ssize.x + 1, -ssize.y + 1, 0)


func registerPhase():
    man.log("debugtools", "This world is in debug mode! A lot of default features are overridden!")
    tlabel = Label.new()
    tlabel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    tlabel.position.y -= 20
    tlabel.text = man.blockList[bid].fullID
    man.get_node("/root/Node3D/Control").add_child(tlabel)
    man.inputRegister(input)
    player.abillities["allowFlight"] = true
    player.abillities["allowBuild"] = true
    itemDisp = MeshInstance3D.new()
    #man.get_node("/root/Node3D/player/head/Camera3D").add_child(itemDisp)
    ItemManager.addToItemLayer(itemDisp)
    #itemDisp.scale = Vector3(0.01, 0.01, 0.01)
    #itemDisp.position = Vector3(-0.1, -0.05, -0.1)
    itemDisp.rotation_degrees = Vector3(10.5, -46, -10.7)
    man.addUpdate(update)
