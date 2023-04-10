#class_name BlockManager already setup by autoload
extends Node

## Manages the setup of mods, voxels, and the world.

# TODO: actual mod selection
## The list of mods to load when the world starts.
var modsToLoad:Array[String] = ["clonecraft", "debugtools"]
## The list of loaded mods. Populates automatically.
var mods := []
## The list of loaded voxels. Populates automatically as voxels are declared.
var blockList:Array[BlockInfo] = []
## A dictionary to translate between a voxel's string name and numerical ID.[br]
## Numerical IDs will vary from world to world. Do not hardcode them.
var blockIDlist := {}
var blockLibrary := VoxelBlockyLibrary.new()
var terrain:VoxelTerrain
var idCounter := 0
var loadDone := false

var _updates:Array[Callable] = []
var _inputList := []
var _addingBlock := false


func addUpdate(c:Callable) -> void:
    _updates.append(c)


func noScript(_pos, _meta) -> void:
    pass


func runRandomTicks(pos, rawID) -> void:
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
    var blockScript:Callable
    var toolClass:String
    var tickable := false
    var tickCB:Callable
    var isAir := false
    var stepsound:String
    var placesound:String
    var breaksound:String


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
            ftoolClass:String,
            fstepsound:String,
            fplacesound:String,
            fbreaksound:String):
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
            blockScript = fscript
        toolClass = ftoolClass


    func setTickable(ftickcb:Callable):
        tickable = true
        tickCB = ftickcb
        blockModel.random_tickable = true


func log(id:String, message:String) -> String:
    var out:String = "[" + Time.get_datetime_string_from_system() + "] [Mod] [" + id + "] " + message
    print(out)
    return out


func startBlockRegister(blockID:String) -> VoxelBlockyModel:
    assert(not(_addingBlock), "You can only register one block at a time!")
    _addingBlock = true
    idCounter += 1
    blockLibrary.voxel_count = idCounter
    var hhh := blockLibrary.create_voxel(idCounter - 1, blockID)
    return(hhh)


func endBlockRegister(blockInfo:BlockInfo):
    assert(_addingBlock, "You need to call 'startBlockRegister' first!")
    _addingBlock = false
    blockList.append(blockInfo)
    blockIDlist[blockInfo.fullID] = blockList.size() - 1
    print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Registered block '" + blockInfo.fullID + "'")


func inputRegister(callback:Callable):
    _inputList.append(callback)


func setup():
    blockLibrary.atlas_size = 10
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
            "shovel",
            "null",
            "null",
            "null"
    )
    airBlock.isAir = true
    endBlockRegister(airBlock)

    for i in modsToLoad:
        print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Fetching script for mod '" + i + "'...")
        mods.append(load("res://mods/" + i + "/" + i + ".gd").new())
    for i in mods:
        if i.get("MODID") == null:
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] One of your mods has no mod ID! It can still load, but this is bad practice. Register phase starting...")
            i.refman(self)
            if i.has_method("registerPhase"):
                i.registerPhase()
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Register phase done!")
        else:
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Beginning register phase for mod '" + i.MODID + "'...")
            i.refman(self)
            if i.has_method("registerPhase"):
                i.registerPhase()
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Register phase for '" + i.MODID + "' done!")
    print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Register phase completed for all mods!")

    blockLibrary.bake()
    terrain = $/root/Node3D/VoxelTerrain
    terrain.mesher.library = blockLibrary
    
    #Ensure every block has an item
    ItemManager.getReady()
    for i in blockList:
        ItemManager.simpleBlockItem(i)
        
    loadDone = true


func _process(delta):
    if loadDone:
        for i in _updates:
            i.call(delta)


func _input(event):
    for i in _inputList:
        i.call(event)
        
        
func quickUniformBlock(
        modID:String,
        blockName:String,
        readableName:String,
        texturePos:Vector2,
        mat:Material,
        breakStrength := 3.0,
        explStrength := 5.0,
        tool := "pickaxe",
        alphaChannel := 0):
    var model = startBlockRegister(modID + blockName)
    model.geometry_type = VoxelBlockyModel.GEOMETRY_CUBE
    model.collision_enabled_0 = true
    model.transparency_index = alphaChannel
    model.cube_tiles_left   = texturePos
    model.cube_tiles_right  = texturePos
    model.cube_tiles_bottom = texturePos
    model.cube_tiles_top    = texturePos
    model.cube_tiles_back   = texturePos
    model.cube_tiles_front  = texturePos
    model.set_material_override(0, mat)
    var bi = BlockManager.BlockInfo.new(
            modID,
            blockName,
            readableName,
            model,
            breakStrength,
            explStrength,
            false,
            false,
            noScript,
            tool,
            "default",
            "default",
            "default"
    )
    endBlockRegister(bi)
