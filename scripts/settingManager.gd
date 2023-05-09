extends Node

#TODO swap to godot's builtin settings system
#TODO better version system
const VERSION = "Alpha 0.0.1"

var settings := []

#TODO load settings from disk
func _ready():
    var j := JSON.new()
    var f := FileAccess.open("res://scripts/baseSettings.json", FileAccess.READ)
    var stat := j.parse(f.get_as_text())
    f.close()
    assert(stat == OK, "error parsing setting tree!")
    settings.append_array(j.get_data())

#TODO save settings to disk


func spawnMenu(content := settings):
    var op:BackingPanel = load("res://gui/backingpanel.tscn").instantiate()
    $"/root".add_child(op)
    for i in content:
        if i["type"] == "folder":
            var c:SettingFolderButton = load("res://scripts/helpers/settings/folderButton.tscn").instantiate()
            c.init(i)
            op.addItem(c)
        elif i["type"] == "float":
            var c:FloatSetting = load("res://scripts/helpers/settings/floatSetting.tscn").instantiate()
            c.init(i)
            op.addItem(c)
        else:
            print("missing setting type: " + i["type"])
