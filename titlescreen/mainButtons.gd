extends GridContainer


func _ready() -> void:
	$"Play".connect("pressed", play)
	$"Options".connect("pressed", openOptions)
	$"ModOpts".connect("pressed", openMods)
	$"Quit".connect("pressed", get_tree().quit)


func play() -> void:
	$"../../singleplayerpanel".show()


func openOptions() -> void:
	var op := SettingManager.spawnMenu()
	$"../../settingpanel".show()
	op.addExit($"../../settingpanel", &"hide")


func openMods() -> void:
	var op:BackingPanel = preload("res://gui/backingpanel.tscn").instantiate()
	SettingManager._layers += 1
	op.setExit(&"gui.generic.back")
	$"/root/title/Control/modpanel".show()
	$"/root/title/Control/modpanel".add_child(op)
	op.addButton(&"gui.mods.modfolder", _modfolder, ProjectSettings.globalize_path("user://mods/"))
	op.addButton(&"gui.mods.gamefolder", _gamefolder, ProjectSettings.globalize_path("res://"))
	op.addButton(&"gui.mods.download", _gamefolder)
	op.addItem(preload("res://gui/warninglabel.tscn").instantiate())
	var i = preload("res://gui/modPckPicker.tscn").instantiate()
	op.addItem(i)
	op.addExit(i, &"save")


func _modfolder():
	OS.shell_open("file://" + ProjectSettings.globalize_path("user://mods/"))


func _gamefolder():
	OS.shell_open("file://" + ProjectSettings.globalize_path("res://"))
