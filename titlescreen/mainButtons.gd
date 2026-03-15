extends GridContainer


@export var singleplayer_panel:Panel
@export var setting_panel:Panel
@export var mod_panel:Panel


func _ready() -> void:
	$"Play".pressed.connect(play)
	$"Options".pressed.connect(open_options)
	$"ModOpts".pressed.connect(open_mods)
	$"Quit".pressed.connect(get_tree().quit)


func play() -> void:
	singleplayer_panel.show()


func open_options() -> void:
	var op := SettingManager.spawnMenu()
	setting_panel.show()
	op.add_exit(setting_panel, &"hide")


func open_mods() -> void:
	var op:BackingPanel = preload("res://gui/backingpanel.tscn").instantiate()
	SettingManager._layers += 1
	op.set_exit(&"gui.generic.back")
	mod_panel.show()
	mod_panel.add_child(op)
	op.add_button(&"gui.mods.modfolder", _mod_folder, ProjectSettings.globalize_path("user://mods/"))
	op.add_button(&"gui.mods.gamefolder", _game_folder, ProjectSettings.globalize_path("res://"))
	# TODO: mod downloader
	op.add_button(&"gui.mods.download", _game_folder)
	op.add_item(preload("res://gui/warninglabel.tscn").instantiate())
	var i:HBoxContainer = preload("res://gui/modPckPicker.tscn").instantiate()
	op.add_item(i)
	op.add_exit(i, &"save")


func _mod_folder():
	OS.shell_open("file://" + ProjectSettings.globalize_path("user://mods/"))


func _game_folder():
	OS.shell_open("file://" + ProjectSettings.globalize_path("res://"))
