extends GridContainer
class_name BoolSetting


var iname:StringName
var default:bool
var path:StringName
var current:bool


func init(i:Dictionary) -> void:
    iname = i["name"]
    $CheckButton.text = Translator.translate(iname)
    default = i["default"]
    path = i["path"]
    current = ProjectSettings.get_setting_with_override(path)
    $CheckButton.button_pressed = current
    $CheckButton.connect("toggled", changeVal)
    $Button.connect("pressed", reset)
    $Button.disabled = (current == default)


func changeVal(newval:bool) -> void:
    current = newval
    $CheckButton.button_pressed = newval
    $Button.disabled = (current == default)
    ProjectSettings.set_setting(path, newval)


func reset() -> void:
    changeVal(default)
