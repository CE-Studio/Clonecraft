extends Object
class_name SettingManager


#TODO better version system
const VERSION = "Alpha 0.0.2"

static var settings := []
static var tick := 0

#TODO load settings from disk
static func _sinit():
    var j := JSON.new()
    var f := FileAccess.open("res://scripts/baseSettings.json", FileAccess.READ)
    var stat := j.parse(f.get_as_text())
    f.close()
    assert(stat == OK, "error parsing setting tree!")
    settings.append_array(j.get_data())

#TODO save settings to disk


static func tickSettings() -> void:
    tick += 1


static func spawnMenu(content := settings):
    var op:BackingPanel = load("res://gui/backingpanel.tscn").instantiate()
    if content == settings:
        op.setExit("gui.generic.back", SettingManager.tickSettings)
    else:
        op.setExit("gui.generic.back")
    Statics.get_node("/root").add_child(op)
    for i in content:
        if i["type"] == "folder":
            var c:SettingFolderButton = load("res://scripts/helpers/settings/folderButton.tscn").instantiate()
            c.init(i)
            op.addItem(c)
        elif i["type"] == "float":
            var c:FloatSetting = load("res://scripts/helpers/settings/floatSetting.tscn").instantiate()
            c.init(i)
            op.addItem(c)
        elif i["type"] == "int":
            var c:FloatSetting = load("res://scripts/helpers/settings/intSetting.tscn").instantiate()
            c.init(i)
            op.addItem(c)
        elif i["type"] == "bool":
            var c:BoolSetting = load("res://scripts/helpers/settings/boolSetting.tscn").instantiate()
            c.init(i)
            op.addItem(c)
        else:
            print("missing setting type: " + i["type"])
