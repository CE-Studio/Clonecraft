extends GridContainer
class_name FloatSetting


var iname:StringName
var min:float
var max:float
var default:float
var path:StringName
var current:float


func init(i:Dictionary) -> void:
    iname = i["name"]
    $Label.text = Translator.translate(iname)
    min = i["slidemin"]
    max = i["slidemax"]
    default = i["default"]
    path = i["path"]
    current = ProjectSettings.get_setting_with_override(path)
    $HSlider.value = current
    $SpinBox.value = current
    $HSlider.connect("value_changed", changeVal)
    $SpinBox.connect("value_changed", changeVal)
    $Button.connect("pressed", reset)
    $Button.disabled = (current == default)


func changeVal(newval:float) -> void:
    current = newval
    $HSlider.value = newval
    $SpinBox.value = newval
    $Button.disabled = (current == default)
    ProjectSettings.set_setting(path, newval)
    
    
func reset() -> void:
    changeVal(default)
