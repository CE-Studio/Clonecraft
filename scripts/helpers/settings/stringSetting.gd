extends GridContainer
class_name StringSetting
## A GUI element that is created and managed by [SettingManager].


var iname:StringName
var default:String
var path:StringName
var current:String


func init(i:Dictionary) -> void:
	iname = i["name"]
	$label.text = Translator.translate(iname)
	default = i["default"]
	path = i["path"]
	current = ProjectSettings.get_setting_with_override(path)
	$lineEdit.text = current
	$lineEdit.placeholder_text = default
	$lineEdit.connect("text_submitted", change_val)
	$lineEdit.connect("focus_exited", foc)
	$Button.connect("pressed", reset)
	$Button.disabled = (current == default)
	
	
func foc():
	change_val($lineEdit.text)


func change_val(new_val:String) -> void:
	current = new_val
	$lineEdit.text = new_val
	$Button.disabled = (current == default)
	ProjectSettings.set_setting(path, new_val)


func reset() -> void:
	change_val(default)
