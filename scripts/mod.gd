class_name Mod
extends RefCounted

## The base class for all mods.
##
## The base class that all gameplay mods should inherit from. It is loaded by ["scripts/blockManager.gd"] during world initialization.[br]
## [br]
## Mods require a [code]registerPhase()[/code] function to load.

## A shorthand reference to BlockManager.
var man:BlockManager
## A premade VoxelTool for the game world.
#TODO dimenstion support?
var tool:VoxelToolTerrain
## A reference to the player.
var player:Player
## A reference to the game world.
var terrain:VoxelTerrain


## Used to initialize some variables before loading.[br]
## Do not override unless you know what you're doing.
func refman(ref):
    man = ref
    terrain = man.get_node("/root/Node3D/VoxelTerrain")
    player = man.get_node("/root/Node3D/player")
    tool = terrain.get_voxel_tool()


## An empty placehloder function.[br]
## Use when you need a reference to a callable but don't want it to do anything.
func noScript(_pos, _meta) -> void:
    pass
