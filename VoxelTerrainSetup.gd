extends VoxelTerrain


func _ready():
    BlockManager.setup()
    $"../"._tool = BlockManager._tool
    $/root/VoxelEngineUpdater_dont_touch_this.process_mode = PROCESS_MODE_ALWAYS


#func _process(delta):
#    pass
