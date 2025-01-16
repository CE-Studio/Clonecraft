extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	var vinfo := Engine.get_version_info()
	text = "Clonecraft "+ SettingManager.VERSION + "
Engine version " + vinfo["string"] + ", " + str("2025") + "
(C) CE Studio 2025. GPLv3. Please distribute!"
	print("[Engine info] [Commit hash] " + vinfo["hash"])
