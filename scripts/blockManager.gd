extends Node
class_name blockManager

var modsToLoad := ["clonecraft", "debugtools"]
var mods = []
var blockList = []
var blockIDlist = {}
var inplist = []
var blockLibrary := VoxelBlockyLibrary.new()
var terrain:VoxelTerrain
var testname = "it worked!"
var idc := 0

func noscript(_pos, _meta) -> void:
    pass
    
var ns := Callable(self, "noscript")

func runRandomTicks():
    pass
    
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
    var tickcb:Callable
    var isAir := false
    
    func _init(fmodID:String, fnameID:String, fnameReadable:String, fblockModel:VoxelBlockyModel,
               fbreakStrength:float, fexplStrength:float, funbreakable:bool, fscripted:bool,
               fscript:Callable, ftoolClass:String):
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
        tickcb = ftickcb
    
func startBlockRegister(blockID:String):
    idc += 1
    blockLibrary.voxel_count = idc
    var hhh = blockLibrary.create_voxel(idc - 1, blockID)
    return(hhh)
    
func endBlockRegister(blockInfo:BlockInfo):
    blockList.append(blockInfo)
    blockIDlist[blockInfo.fullID] = blockList.size() - 1

func inputRegister(callback:Callable):
    inplist.append(callback)

func setup():
    blockLibrary.atlas_size = 6
    
    var airModel = startBlockRegister("clonecraft:air")
    airModel.geometry_type = VoxelBlockyModel.GEOMETRY_NONE
    var airBlock := BlockInfo.new("clonecraft", "air", "Air", airModel, 0, 0, true, false, ns, "shovel")
    airBlock.isAir = true
    endBlockRegister(airBlock)
    
    #TODO: actual mod loading logic
    for i in modsToLoad:
        mods.append(load("res://mods/" + i + "/" + i + ".gd").new())
    for i in mods:
        i.refman(self)
        if i.has_method("registerPhase"):
            i.registerPhase()
    
    blockLibrary.bake()
    print(blockLibrary.get_voxel(1).get_material_override(0))
    terrain = $/root/Node3D/VoxelTerrain
    terrain.mesher.library = blockLibrary

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
func _input(event):
    for i in inplist:
        i.call(event)
