extends GridContainer
class_name BoolSetting
## A GUI element that is created and managed by [SettingManager].


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
	$CheckButton.connect("toggled", change_val)
	$Button.connect("pressed", reset)
	$Button.disabled = (current == default)


func change_val(newval:bool) -> void:
	current = newval
	$CheckButton.button_pressed = newval
	$Button.disabled = (current == default)
	ProjectSettings.set_setting(path, newval)


func reset() -> void:
	change_val(default)
