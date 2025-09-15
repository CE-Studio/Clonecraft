extends VoxelTerrain


func _ready() -> void:
	if WorldControl.generator.has_method("setup_seed"):
		WorldControl.generator.setup_seed(WorldControl.seed)
	BlockManager.setup()
	if WorldControl.generator.has_method("setup_ids"):
		WorldControl.generator.setup_ids()
	generator = WorldControl.generator
	$"../"._tool = BlockManager._tool
	$/root/VoxelEngineUpdater_dont_touch_this.process_mode = PROCESS_MODE_ALWAYS
	
	
