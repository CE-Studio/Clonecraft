extends Node
class_name BlockManager

## Manages the setup of mods, voxels, and the world.

# TODO actual mod selection
## The list of mods to load when the world starts.[br]
## Static
static var modsToLoad:Array[String] = ["clonecraft", "debugtools"]
## The list of loaded mods. Populates automatically.[br]
## Static
static var mods:Array[Mod] = []
## The list of loaded voxels. Populates automatically as voxels are declared.[br]
## Static
static var blockList:Array[BlockInfo] = []
## A dictionary to translate between a voxel's string name and numerical ID.[br]
## Numerical IDs will vary from world to world. Do not hardcode them. 
## Caching, however, is strongly encuraged.[br]
## Static
static var blockIDlist := {}
## The world's [VoxelBlockyLibrary].[br]
## Static
static var blockLibrary := VoxelBlockyLibrary.new()
## The world's [VoxelTerrain].[br]
## Static
static var terrain:VoxelTerrain
## Counts the number of registered voxels.[br]
## Static
static var idCounter := 0
## Turns [code]true[/code] when the world is fully initalized.[br]
## Static
static var loadDone := false
## A static refrence to the BlockManager singleton.[br]
## [code]null[/code] until the world scene loads.[br]
## You won't typically need to use this.[br]
## Static
static var instance:BlockManager

## A list of voxel positions to update this simulation tick.[br]
## You probably want to use [member pendingBlockUpdates] instead.[br]
## Static
static var blockUpdates:Array[Vector3i] = []
## A list of voxel positions to update on the next simulation tick.[br]
## Static
static var pendingBlockUpdates:Array[Vector3i] = []

static var _updates:Array[Callable] = []
static var _inputList := []
static var _addingBlock := false
static var _tdisp:PackedScene = preload("res://scripts/helpers/tickDisplay.tscn")
static var _udisp:PackedScene = preload("res://scripts/helpers/updateDisplay.tscn")
static var _tool:VoxelToolTerrain
static var _newmodel:VoxelBlockyModel


## Get the [BlockInfo] tied to a specific ID string.[br]
## Static
static func getBlockID(id:StringName) -> BlockInfo:
    return blockList[blockIDlist[id]]


## Register a [Callable] to be called every simulation tick.[br]
## Static
static func addUpdate(c:Callable) -> void:
    _updates.append(c)


static func _tickBlock(pos:Vector3i, rawID:int) -> void:
    if ProjectSettings.get_setting("gameplay/debug/show_updates"):
        var disp:MeshInstance3D = _tdisp.instantiate()
        disp.position = (Vector3(pos.x, pos.y, pos.z) + Vector3(0.5, 0.5, 0.5))
        terrain.add_child(disp)
        
    var block:BlockInfo = blockList[rawID]
    if block.tickable:
        block.tickCB.call(pos)


## Run all pending block updates.[br]
## Called automatically every simulation tick.[br]
## Static
static func runBlockUpdates() -> void:
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
    var nameReadable:StringName
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
            fnameReadable:StringName,
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
        nameReadable = Translator.translate(fnameReadable)
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


    func setTickable(ftickcb:Callable) -> void:
        tickable = true
        tickCB = ftickcb
        blockModel.random_tickable = true


## Output a message to the debug log.[br]
## [color=red][b]YOU SHOULD USE THIS INSTEAD OF PRINT.[/b][/color][br]
## Static
@warning_ignore("SHADOWED_GLOBAL_IDENTIFIER")
static func log(id:String, message:String) -> String:
    var out:String = "[" + Time.get_datetime_string_from_system() + "] [Mod] [" + id + "] " + message
    print(out)
    if ProjectSettings.get_setting("gameplay/debug/log_to_chat"):
        Chat.pushText(out)
    return out


## Begin registering a new voxel.[br]
## See [Voxdat], [method endBlockRegister] and [BlockManager.BlockInfo].[br]
## Static
static func startBlockRegister(blockID:StringName, type:Voxdat.vox) -> VoxelBlockyModel:
    assert(not(_addingBlock), "You can only register one block at a time!")
    _addingBlock = true
    idCounter += 1
    match type:
        Voxdat.vox.GEOMETRY_CUBE:
            _newmodel = VoxelBlockyModelCube.new()
            _newmodel.atlas_size_in_tiles = Vector2i(10, 10)
        Voxdat.vox.GEOMETRY_MESH:
            _newmodel = VoxelBlockyModelMesh.new()
        Voxdat.vox.GEOMETRY_NONE:
            _newmodel = VoxelBlockyModelEmpty.new()

    return(_newmodel)


## Finish registering a voxel.[br]
## See [method startBlockRegister] and [BlockManager.BlockInfo].[br]
## Static
static func endBlockRegister(blockInfo:BlockInfo) -> void:
    assert(_addingBlock, "You need to call 'startBlockRegister' first!")
    _addingBlock = false
    blockList.append(blockInfo)
    blockIDlist[blockInfo.fullID] = blockList.size() - 1
    blockLibrary.add_model(_newmodel)
    print(
        "[" + Time.get_datetime_string_from_system() + "] [BlockManager] Registered block '" 
        + blockInfo.fullID + "'"
    )


## Register a function to handle user inputs.[br]
## Analogous to [method Node._input][br]
## Static
static func inputRegister(callback:Callable) -> void:
    _inputList.append(callback)


# TODO finalize and document the loading order
## Initalize the block manager.[br]
## You probably don't want to call this.[br]
## Static
static func setup() -> void:
    terrain = Statics.get_node("/root/Node3D/VoxelTerrain")
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
            Callable(),
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

    Mod.refman()
    for i in modsToLoad:
        print(
            "[" + Time.get_datetime_string_from_system() + 
            "] [BlockManager] Fetching script for mod '" + i + "'..."
        )
        mods.append(load("res://mods/" + i + "/" + i + ".gd").new())
    for i in mods:
        if i.get("MODID") == null:
            print(
                "[" + Time.get_datetime_string_from_system() + 
                "] [BlockManager] One of your mods has no mod ID! It can still load," + 
                "but this is bad practice. Register phase starting..."
            )
            if i.has_method("registerPhase"):
                i.registerPhase()
            print(
                "[" + Time.get_datetime_string_from_system() + 
                "] [BlockManager] Register phase done!"
            )
        else:
            print(
                "[" + Time.get_datetime_string_from_system() + 
                "] [BlockManager] Beginning register phase for mod '" + i.MODID + "'..."
            )
            if i.has_method("registerPhase"):
                i.registerPhase()
            print(
                "[" + Time.get_datetime_string_from_system() + 
                "] [BlockManager] Register phase for '" + i.MODID + "' done!"
            )
    print(
        "[" + Time.get_datetime_string_from_system() + 
        "] [BlockManager] Register phase completed for all mods!"
    )

    blockLibrary.bake()
    terrain.mesher.library = blockLibrary

    #Ensure every block has an item
    ItemManager.getReady()
    for i in blockList:
        ItemManager.simpleBlockItem(i)

    loadDone = true


func _process(delta) -> void:
    if loadDone:
        for i in _updates:
            i.call(delta)
        BlockManager.runBlockUpdates()


func _input(event) -> void:
    for i in _inputList:
        i.call(event)
        
        
func _ready() -> void:
    instance = self


# TODO abstract away VoxelBlockyModel to pin the features
# TODO unit testing for abstractions ig??? feels like the right thing to do for compatibillity
## Quickly and easily create a simple voxel that has the same texture on all sides.[br]
## [param modID] is typically the ID of your mod, but can be anything if needed.[br]
## [param blockName] is the ID of your voxel.[br]
## [param readableName] is the name of your voxel that is shown to the player.
## Supports translation keys.[br]
## [param texturePos] is the UV position of the voxel's texture.[br]
## [param mat] is the [Material] to apply to the voxel. The supplied texture should be a
## 10x10 atlas.[br]
## [param breakStrength] is how hard it is for the player to break the voxel.[br]
## [param explosionStrength] is how hard it is for an explosion to break the voxel.[br]
## [param tool] is the kind of tool that is most effective at breaking the voxel.[br]
## [param alphaChannel] see [member VoxelBlockyModel.transparency_index][br]
## Static
static func quickUniformBlock(
        modID:StringName,
        blockName:StringName,
        readableName:String,
        texturePos:Vector2,
        mat:Material,
        breakStrength := 3.0,
        explosionStrength := 5.0,
        tool := &"pickaxe",
        alphaChannel := 0) -> void:
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
            explosionStrength,
            false,
            false,
            Callable(),
            tool,
            "default",
            "default",
            "default"
    )
    endBlockRegister(bi)


## Places a voxel at the specified position.
## [param pos] is the position.[br]
## [param blockID] is the id of the voxel you want to place (in [code]modID:blockID[/code] format).[br]
## [param drop] determines if the voxel already at the position will drop an item when replaced.[br]
## [param update] determins if the operation will send block updates to neighoring voxels.[br]
## [param force] forces the operation to replace any voxel, not just ones flagged as replaceable.[br]
## Returns [code]true[/code] if the operation succeeded.[br]
## Static
static func setBlock(pos:Vector3i, blockID:StringName, drop := true, update := true, force := false) -> bool:
    var willSet := force

    var oldBlock:BlockInfo = blockList[_tool.get_voxel(pos)]
    if not(willSet):
        if oldBlock.properties.has(&"replaceable") or blockList[blockIDlist[blockID]].properties.has(&"air"):
            willSet = true

    if willSet:
        if drop:
            var itemID := oldBlock.dropItem
            if itemID != &"null":
                var item:ItemManager.ItemStack
                if itemID == &"*":
                    item = ItemManager.ItemStack.new(oldBlock.fullID, 1)
                elif itemID == &"script":
                    pass
                else:
                    item = ItemManager.ItemStack.new(itemID, 1)
                ItemManager.spawnWorldItem(item, Vector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5))

        _tool.set_voxel(pos, blockIDlist[blockID])

        if update:
            pendingBlockUpdates.append(pos)
            pendingBlockUpdates.append(pos + Vector3i.UP)
            pendingBlockUpdates.append(pos + Vector3i.DOWN)
            pendingBlockUpdates.append(pos + Vector3i.FORWARD)
            pendingBlockUpdates.append(pos + Vector3i.BACK)
            pendingBlockUpdates.append(pos + Vector3i.LEFT)
            pendingBlockUpdates.append(pos + Vector3i.RIGHT)

    return willSet


## Gets the [BlockInfo] for the voxel at the specified position.[br]
## Static
static func getBlock(pos:Vector3) -> BlockInfo:
    var npos = Vector3i(floor(pos.x), floor(pos.y), floor(pos.z))
    return blockList[_tool.get_voxel(npos)]

