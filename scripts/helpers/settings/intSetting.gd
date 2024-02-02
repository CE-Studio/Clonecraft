extends GridContainer
class_name IntSetting
## A GUI element that is created and managed by [SettingManager].


var iname:StringName
var minv:int
var maxv:int
var default:int
var path:StringName
var current:int


func init(i:Dictionary) -> void:
	iname = i["name"]
	$Label.text = Translator.translate(iname)
	minv = i["slidemin"]
	maxv = i["slidemax"]
	default = i["default"]
	path = i["path"]
	current = ProjectSettings.get_setting_with_override(path)
	$HSlider.min_value = minv
	$HSlider.max_value = maxv
	$HSlider.value = current
	$SpinBox.value = current
	$HSlider.connect("value_changed", changeVal)
	$SpinBox.connect("value_changed", changeVal)
	$Button.connect("pressed", reset)
	$Button.disabled = (current == default)


func changeVal(newval:int) -> void:
	current = newval
	$HSlider.value = newval
	$SpinBox.value = newval
	$Button.disabled = (current == default)
	ProjectSettings.set_setting(path, newval)


func reset() -> void:
	changeVal(default)
