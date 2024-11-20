extends VoxelTerrain


func _ready() -> void:
	if WorldControl.generator.has_method("setupSeed"):
		WorldControl.generator.setupSeed(WorldControl.seed)
	BlockManager.setup()
	if WorldControl.generator.has_method("setupIDS"):
		WorldControl.generator.setupIDS()
	generator = WorldControl.generator
	$"../"._tool = BlockManager._tool
	$/root/VoxelEngineUpdater_dont_touch_this.process_mode = PROCESS_MODE_ALWAYS
	
	
