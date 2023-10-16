extends Node
class_name AutoScaler

## Handles the automatic scaling of the game's UI.
##
## Will atuomatically set the scale of the game's UI elements when the window is resized, 
## or set the scale to the player's choice if autoscaling is turned off.

## A static refrence to the AutoScaler singleton.[br]
## Static
static var instance:AutoScaler


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().root.size_changed.connect(resize)
    instance = self
    

## Forces the scale of the UI to update.[br]
## Use via [code]AutoScaler.instance.resize()[/code]
func resize() -> void:
    if ProjectSettings.get_setting("gameplay/ui/auto_scale"):
        var j := get_viewport()
        var k := mini(j.size.x, j.size.y)
        get_window().content_scale_factor = k / 1080.0
    else:
        get_window().content_scale_factor = ProjectSettings.get_setting("gameplay/ui/scale")
        
        
func _settingsChanged() -> void:
    resize()
