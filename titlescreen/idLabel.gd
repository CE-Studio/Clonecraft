extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	var version_info := Engine.get_version_info()
	text = "Clonecraft "+ SettingManager.VERSION + "
Engine version " + version_info["string"] + ", " + str("2025") + "
(C) CE Studio 2025. AGPLv3. Please distribute!"
	print("[Engine info] [Commit hash] " + version_info["hash"])
