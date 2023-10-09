extends Object
class_name SettingManager


# TODO better version system
const VERSION = "Alpha 0.0.2"

static var settings := []


# TODO load settings from disk
static func _sinit() -> void:
    var j := JSON.new()
    var f := FileAccess.open("res://scripts/baseSettings.json", FileAccess.READ)
    var stat := j.parse(f.get_as_text())
    f.close()
    assert(stat == OK, "error parsing setting tree!")
    settings.append_array(j.get_data())

# TODO save settings to disk


static func _recur(n:Node) -> void:
        if n.has_method("_settingsChanged"):
            n._settingsChanged()
        for i in n.get_children():
            _recur(i)


static func broadcast() -> void:
    _recur(Statics.get_node("/root"))


static func spawnMenu(content := settings) -> void:
    var op:BackingPanel = load("res://gui/backingpanel.tscn").instantiate()
    if content == settings:
        op.setExit("gui.generic.back", SettingManager, &"broadcast")
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
