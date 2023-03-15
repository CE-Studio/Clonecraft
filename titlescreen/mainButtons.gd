extends GridContainer


func _ready():
    $"Play".connect("pressed", play)
    $"Options".connect("pressed", openOptions)
    $"ModOpts".connect("pressed", openMods)
    $"Quit".connect("pressed", get_tree().quit)


func play():
    get_tree().change_scene_to_file("res://node_3d.tscn")


func openOptions():
    var h = ProjectSettings.get_property_list()
    for i in h:
        print(i["name"])
    var op = load("res://gui/backingpanel.tscn").instantiate()
    $"/root".add_child(op)


func openMods():
    var op = load("res://gui/backingpanel.tscn").instantiate()
    $"/root".add_child(op)
    op.addItem(load("res://gui/warninglabel.tscn").instantiate())
    var l := LinkButton.new()
    l.text = "Open mods folder"
    l.uri = "file://" + ProjectSettings.globalize_path("user://")
    op.addItem(l)
    l = LinkButton.new()
    l.text = "Open game folder"
    l.uri = "file://" + ProjectSettings.globalize_path("res://")
    op.addItem(l)
