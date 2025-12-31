extends GridContainer


func _ready() -> void:
	$"Play".connect("pressed", play)
	$"Options".pressed.connect(open_options)
	$"ModOpts".pressed.connect(open_mods)
	$"Quit".pressed.connect(get_tree().quit)


func play() -> void:
	$"../../singleplayerpanel".show()


func open_options() -> void:
	var op := SettingManager.spawnMenu()
	$"../../settingpanel".show()
	op.add_exit($"../../settingpanel", &"hide")


func open_mods() -> void:
	var op:BackingPanel = preload("res://gui/backingpanel.tscn").instantiate()
	SettingManager._layers += 1
	op.setExit(&"gui.generic.back")
	$"/root/title/Control/modpanel".show()
	$"/root/title/Control/modpanel".add_child(op)
	op.add_button(&"gui.mods.modfolder", _mod_folder, ProjectSettings.globalize_path("user://mods/"))
	op.add_button(&"gui.mods.gamefolder", _game_folder, ProjectSettings.globalize_path("res://"))
	# TODO: mod downloader
	op.add_button(&"gui.mods.download", _game_folder)
	op.add_item(preload("res://gui/warninglabel.tscn").instantiate())
	var i = preload("res://gui/modPckPicker.tscn").instantiate()
	op.add_item(i)
	op.add_exit(i, &"save")


func _mod_folder():
	OS.shell_open("file://" + ProjectSettings.globalize_path("user://mods/"))


func _game_folder():
	OS.shell_open("file://" + ProjectSettings.globalize_path("res://"))
