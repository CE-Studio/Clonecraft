extends Node
class_name blockManager

var mods = []
var blockList = []
var blockIDlist = {}
var blockLibrary := VoxelBlockyLibrary.new()
var terrain:VoxelTerrain
var testname = "it worked!"
var idc := 0

func noscript(_pos, _meta) -> void:
    pass
    
var ns := Callable(self, "noscript")
    
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
    
    func _init(fmodID:String, fnameID:String, fnameReadable:String, fblockModel:VoxelBlockyModel,
               fbreakStrength:float, fexplStrength:float, funbreakable:bool, fscripted:bool,
               fscript:Callable):
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
    
func startBlockRegister(name:String):
    idc += 1
    blockLibrary.voxel_count = idc
    var hhh = blockLibrary.create_voxel(idc - 1, name)
    return(hhh)
    
func endBlockRegister(blockInfo:BlockInfo):
    blockList.append(blockInfo)
    blockIDlist[blockInfo.fullID] = blockList.size() - 1

# Called when the node enters the scene tree for the first time.
func setup():
    blockLibrary.atlas_size = 5
    
    var airModel = startBlockRegister("clonecraft:air")
    airModel.geometry_type = VoxelBlockyModel.GEOMETRY_NONE
    var airBlock := BlockInfo.new("clonecraft", "air", "Air", airModel, 0, 0, true, false, ns)
    endBlockRegister(airBlock)
    
    #TODO: actual mod loading logic
    mods.append(load("res://mods/clonecraft/clonecraft.gd").new())
    for i in mods:
        i.refman(self)
        i.registerPhase()
    
    blockLibrary.bake()
    print(blockLibrary.get_voxel(1).get_material_override(0))
    terrain = $/root/Node3D/VoxelTerrain
    terrain.mesher.library = blockLibrary

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
