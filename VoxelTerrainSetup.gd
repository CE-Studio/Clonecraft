extends VoxelTerrain


# Called when the node enters the scene tree for the first time.
func _ready():
    var bm = $/root/BlockManager
    print(bm.testname)
    bm.setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
