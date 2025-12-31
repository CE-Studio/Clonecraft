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


func change_val(new_val:bool) -> void:
	current = new_val
	$CheckButton.button_pressed = new_val
	$Button.disabled = (current == default)
	ProjectSettings.set_setting(path, new_val)


func reset() -> void:
	change_val(default)
