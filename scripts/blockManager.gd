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

var blockUpdates:Array[Vector3i] = []
var pendingBlockUpdates:Array[Vector3i] = []

var _updates:Array[Callable] = []
var _inputList := []
var _addingBlock := false
var _tdisp:PackedScene = preload("res://scripts/helpers/tickDisplay.tscn")
var _udisp:PackedScene = preload("res://scripts/helpers/updateDisplay.tscn")
var _tool:VoxelToolTerrain
var _newmodel:VoxelBlockyModel


func getBlockID(id:String) -> BlockInfo:
    return blockList[blockIDlist[id]]


func addUpdate(c:Callable) -> void:
    _updates.append(c)


func noScript(_pos, _meta) -> void:
    pass


func runRandomTicks(pos, rawID) -> void:
    if ProjectSettings.get_setting("gameplay/debug/show_updates"):
        var disp:MeshInstance3D = _tdisp.instantiate()
        disp.position = (Vector3(pos.x, pos.y, pos.z) + Vector3(0.5, 0.5, 0.5))
        terrain.add_child(disp)
    var block:BlockInfo = blockList[rawID]
    if block.tickable:
        block.tickCB.call(pos)


func runBlockUpdates() -> void:
    blockUpdates = pendingBlockUpdates
    pendingBlockUpdates = []
    for i in blockUpdates:
        if ProjectSettings.get_setting("gameplay/debug/show_updates"):
            var disp:MeshInstance3D = _udisp.instantiate()
            disp.position = (Vector3(i.x, i.y, i.z) + Vector3(0.5, 0.5, 0.5))
            terrain.add_child(disp)


class BlockInfo:
    var modID:StringName
    var nameID:StringName
    var fullID:StringName
    var nameReadable:String
    var blockModel:VoxelBlockyModel
    var breakStrength:float
    var explStrength:float
    var unbreakable:bool
    var scripted:bool
    var blockScript:Callable
    var toolClass:StringName
    var tickable := false
    var tickCB:Callable
    var stepsound:StringName
    var placesound:StringName
    var breaksound:StringName
    var dropItem:StringName
    var properties:Array[StringName]


    func _init(
            fmodID:StringName,
            fnameID:StringName,
            fnameReadable:String,
            fblockModel:VoxelBlockyModel,
            fbreakStrength:float,
            fexplStrength:float,
            funbreakable:bool,
            fscripted:bool,
            fscript:Callable,
            ftoolClass:StringName,
            fstepsound:StringName,
            fplacesound:StringName,
            fbreaksound:StringName,
            fdropitem := &"*"):
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
        stepsound = fstepsound
        placesound = fplacesound
        breaksound = fbreaksound
        dropItem = fdropitem


    func setTickable(ftickcb:Callable):
        tickable = true
        tickCB = ftickcb
        blockModel.random_tickable = true


@warning_ignore("shadowed_global_identifier")
func log(id:String, message:String) -> String:
    var out:String = "[" + Time.get_datetime_string_from_system() + "] [Mod] [" + id + "] " + message
    print(out)
    return out


func startBlockRegister(blockID:String, type:Voxdat.vox) -> VoxelBlockyModel:
    assert(not(_addingBlock), "You can only register one block at a time!")
    _addingBlock = true
    idCounter += 1
    #blockLibrary.voxel_count = idCounter
    #var hhh := blockLibrary.create_voxel(idCounter - 1, blockID)
    match type:
        0:
            _newmodel = VoxelBlockyModelCube.new()
            _newmodel.atlas_size_in_tiles = Vector2i(10, 10)
        1:
            _newmodel = VoxelBlockyModelMesh.new()
        2:
            _newmodel = VoxelBlockyModelEmpty.new()

    return(_newmodel)


func endBlockRegister(blockInfo:BlockInfo):
    assert(_addingBlock, "You need to call 'startBlockRegister' first!")
    _addingBlock = false
    blockList.append(blockInfo)
    blockIDlist[blockInfo.fullID] = blockList.size() - 1
    blockLibrary.add_model(_newmodel)
    print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Registered block '" + blockInfo.fullID + "'")


func inputRegister(callback:Callable):
    _inputList.append(callback)


func setup():
    terrain = $/root/Node3D/VoxelTerrain
    _tool = terrain.get_voxel_tool()
    blockLibrary.atlas_size = 10
    var airModel = startBlockRegister("clonecraft:air", Voxdat.vox.GEOMETRY_NONE)
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
            "null",
            "null"
    )
    airBlock.properties.append(&"air")
    airBlock.properties.append(&"replaceable")
    airBlock.properties.append(&"incompleteHitbox")
    endBlockRegister(airBlock)

    Mod.refman(self)
    for i in modsToLoad:
        print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Fetching script for mod '" + i + "'...")
        mods.append(load("res://mods/" + i + "/" + i + ".gd").new())
    for i in mods:
        if i.get("MODID") == null:
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] One of your mods has no mod ID! It can still load, but this is bad practice. Register phase starting...")
            if i.has_method("registerPhase"):
                i.registerPhase()
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Register phase done!")
        else:
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Beginning register phase for mod '" + i.MODID + "'...")
            #i.refman(self)
            if i.has_method("registerPhase"):
                i.registerPhase()
            print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Register phase for '" + i.MODID + "' done!")
    print("[" + Time.get_datetime_string_from_system() + "] [BlockManager] Register phase completed for all mods!")

    blockLibrary.bake()
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
        runBlockUpdates()


func _input(event):
    for i in _inputList:
        i.call(event)

#TODO abstract away VoxelBlockyModel to pin the features
#TODO unit testing for abstractions ig??? feels like the right thing to do for compatibillity
func quickUniformBlock(
        modID:StringName,
        blockName:StringName,
        readableName:String,
        texturePos:Vector2,
        mat:Material,
        breakStrength := 3.0,
        explStrength := 5.0,
        tool := &"pickaxe",
        alphaChannel := 0):
    var model = startBlockRegister(modID + blockName, Voxdat.vox.GEOMETRY_CUBE)
    model.set_mesh_collision_enabled(0, true)
    model.transparency_index = alphaChannel
    model.tile_left   = texturePos
    model.tile_right  = texturePos
    model.tile_bottom = texturePos
    model.tile_top    = texturePos
    model.tile_back   = texturePos
    model.tile_front  = texturePos
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


func setBlock(pos:Vector3i, type:String, drop := true, update := true, force := false) -> bool:
    var willSet := force

    var i:BlockInfo = blockList[_tool.get_voxel(pos)]
    if not(willSet):
        if i.properties.has(&"replaceable") or blockList[blockIDlist[type]].properties.has(&"air"):
            willSet = true

    if willSet:
        if drop:
            var h := i.dropItem
            if h != &"null":
                var j:ItemManager.ItemStack
                if h == &"*":
                    j = ItemManager.ItemStack.new(i.fullID, 1)
                elif h == &"script":
                    pass
                else:
                    j = ItemManager.ItemStack.new(h, 1)
                ItemManager.spawnWorldItem(j, Vector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5))

        _tool.set_voxel(pos, blockIDlist[type])

        if update:
            pendingBlockUpdates.append(pos)
            pendingBlockUpdates.append(pos + Vector3i.UP)
            pendingBlockUpdates.append(pos + Vector3i.DOWN)
            pendingBlockUpdates.append(pos + Vector3i.FORWARD)
            pendingBlockUpdates.append(pos + Vector3i.BACK)
            pendingBlockUpdates.append(pos + Vector3i.LEFT)
            pendingBlockUpdates.append(pos + Vector3i.RIGHT)

    return willSet


func getBlock(pos:Vector3) -> BlockInfo:
    var npos = Vector3i(floor(pos.x), floor(pos.y), floor(pos.z))
    return blockList[_tool.get_voxel(npos)]

