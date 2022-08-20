#class_name BlockManager already setup by autoload
extends Node

# TODO: actual mod selection
var modsToLoad := ["clonecraft", "debugtools"]
var mods := []
var blockList := []
var blockIDlist := {}
var inplist := []
var blockLibrary := VoxelBlockyLibrary.new()
var terrain:VoxelTerrain
var idCounter := 0


func noScript(_pos, _meta) -> void:
    pass


func runRandomTicks(pos, rawID):
    var block:BlockInfo = blockList[rawID]
    if block.tickable:
        block.tickCB.call(pos)


class BlockInfo:
    var modID:String
    var nameID:String
    var fullID:String
    var nameReadable:String
    var blockModel:VoxelBlockyModel
    var breakStrength:float
    var explStrength:float
    var unbreakable:bool
    var scripted:bool
    var script:Callable
    var toolClass:String
    var tickable := false
    var tickCB:Callable
    var isAir := false


    func _init(
            fmodID:String,
            fnameID:String,
            fnameReadable:String,
            fblockModel:VoxelBlockyModel,
            fbreakStrength:float,
            fexplStrength:float,
            funbreakable:bool,
            fscripted:bool,
            fscript:Callable,
            ftoolClass:String):
        modID = fmodID
        nameID = fnameID
        fullID = fmodID + ":" + fnameID
        nameReadable = fnameReadable
        blockModel = fblockModel
        breakStrength = fbreakStrength
        explStrength = fexplStrength
        unbreakable = funbreakable
        scripted = fscripted
        if scripted:
            script = fscript
        toolClass = ftoolClass


    func setTickable(ftickcb:Callable):
        tickable = true
        tickCB = ftickcb
        blockModel.random_tickable = true


@warning_ignore(shadowed_global_identifier)
func log(id:String, message:String):
    print("[Mod] [" + id + "] " + message)


func startBlockRegister(blockID:String):
    idCounter += 1
    blockLibrary.voxel_count = idCounter
    var hhh = blockLibrary.create_voxel(idCounter - 1, blockID)
    return(hhh)


func endBlockRegister(blockInfo:BlockInfo):
    blockList.append(blockInfo)
    blockIDlist[blockInfo.fullID] = blockList.size() - 1
    print("[BlockManager] Registered block '" + blockInfo.fullID + "'")


func inputRegister(callback:Callable):
    inplist.append(callback)


func setup():
    blockLibrary.atlas_size = 6
    var airModel = startBlockRegister("clonecraft:air")
    airModel.geometry_type = VoxelBlockyModel.GEOMETRY_NONE
    var airBlock := BlockInfo.new(
            "clonecraft",
            "air",
            "Air",
            airModel,
            0,
            0,
            true,
            false,
            noScript,
            "shovel"
    )
    airBlock.isAir = true
    endBlockRegister(airBlock)

    for i in modsToLoad:
        print("[BlockManager] Fetching script for mod '" + i + "'...")
        mods.append(load("res://mods/" + i + "/" + i + ".gd").new())
    for i in mods:
        if i.get("MODID") == null:
            print("[BlockManager] One of your mods has no mod ID! It can still load, but this is bad practice. Register phase starting...")
            i.refman(self)
            if i.has_method("registerPhase"):
                i.registerPhase()
            print("[BlockManager] Register phase done!")
        else:
            print("[BlockManager] Beginning register phase for mod '" + i.MODID + "'...")
            i.refman(self)
            if i.has_method("registerPhase"):
                i.registerPhase()
            print("[BlockManager] Register phase for '" + i.MODID + "' done!")
    print("[BlockManager] Register phase completed for all mods!")

    blockLibrary.bake()
    terrain = $/root/Node3D/VoxelTerrain
    terrain.mesher.library = blockLibrary


func _process(delta):
    pass


func _input(event):
    for i in inplist:
        i.call(event)
