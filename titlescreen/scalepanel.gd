extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func _on_enable_pressed():
    ProjectSettings.set_setting("gameplay/ui/auto_scale", true)
    hide()


func _on_disabled_pressed():
    ProjectSettings.set_setting("gameplay/ui/auto_scale", false)
    hide()
