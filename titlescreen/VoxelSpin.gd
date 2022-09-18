extends VoxelTerrain


func _process(delta):
    rotation.y += (delta / 30)
