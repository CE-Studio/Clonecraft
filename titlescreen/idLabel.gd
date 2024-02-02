extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
    var vinfo := Engine.get_version_info()
    text = "Clonecraft "+ SettingManager.VERSION + "
Engine version " + vinfo["string"] + ", " + str(vinfo["year"]) + "
Copyright (GPLv3) CE Studio 2024. Please distribute!"
    print(vinfo["hash"])
