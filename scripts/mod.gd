extends Node
class_name Mod

var man:blockManager
var tool:VoxelToolTerrain
var player:Player
var terrain:VoxelTerrain

func refman(ref):
    man = ref
    terrain = man.get_node("/root/Node3D/VoxelTerrain")
    player = man.get_node("/root/Node3D/player")
    tool = terrain.get_voxel_tool()

func noscript(_pos, _meta) -> void:
    pass
    
var ns := Callable(self, "noscript")
