extends GridContainer
class_name FloatSetting
## A GUI element that is created and managed by [SettingManager].


var iname:StringName
var min_value:float
var max_value:float
var default:float
var path:StringName
var current:float


func init(i:Dictionary) -> void:
	iname = i["name"]
	$Label.text = Translator.translate(iname)
	min_value = i["slidemin"]
	max_value = i["slidemax"]
	default = i["default"]
	path = i["path"]
	current = ProjectSettings.get_setting_with_override(path)
	$HSlider.min_value = min_value
	$HSlider.max_value = max_value
	$HSlider.value = current
	$SpinBox.value = current
	$HSlider.connect("value_changed", change_val)
	$SpinBox.connect("value_changed", change_val)
	$Button.connect("pressed", reset)
	$Button.disabled = (current == default)


func change_val(new_val:float) -> void:
	current = new_val
	$HSlider.value = new_val
	$SpinBox.value = new_val
	$Button.disabled = (current == default)
	ProjectSettings.set_setting(path, new_val)


func reset() -> void:
	change_val(default)
