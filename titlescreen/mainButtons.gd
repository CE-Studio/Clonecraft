extends GridContainer


func _ready() -> void:
    $"Play".connect("pressed", play)
    $"Options".connect("pressed", openOptions)
    $"ModOpts".connect("pressed", openMods)
    $"Quit".connect("pressed", get_tree().quit)


func play() -> void:
    $"../../singleplayerpanel".show()


func openOptions() -> void:
    SettingManager.spawnMenu()


func openMods() -> void:
    var op:BackingPanel = load("res://gui/backingpanel.tscn").instantiate()
    op.setExit(&"gui.generic.back")
    $"/root".add_child(op)
    op.addItem(load("res://gui/warninglabel.tscn").instantiate())
    var l := LinkButton.new()
    l.text = Translator.translate(&"gui.mods.modfolder")
    l.uri = "file://" + ProjectSettings.globalize_path("user://mods/")
    op.addItem(l)
    l = LinkButton.new()
    l.text = Translator.translate(&"gui.mods.gamefolder")
    l.uri = "file://" + ProjectSettings.globalize_path("res://")
    op.addItem(l)
