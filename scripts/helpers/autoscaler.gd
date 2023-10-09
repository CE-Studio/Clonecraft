extends Node
class_name AutoScaler


static var instance:AutoScaler


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().root.size_changed.connect(resize)
    instance = self
    
    
func resize() -> void:
    if ProjectSettings.get_setting("gameplay/ui/auto_scale"):
        var j := get_viewport()
        var k := mini(j.size.x, j.size.y)
        get_window().content_scale_factor = k / 1080.0
    else:
        get_window().content_scale_factor = ProjectSettings.get_setting("gameplay/ui/scale")
        
        
func _settingsChanged() -> void:
    resize()
