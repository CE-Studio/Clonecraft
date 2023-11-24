extends Panel


func _ready() -> void:
    get_tree().root.add_child(AutoScaler.new())
    if not(ProjectSettings.get_setting("gameplay/ui/auto_scale_shown")):
        var h := DisplayServer.screen_get_usable_rect()
        var i := mini(h.size.x, h.size.y)
        if i > 1080:
            ProjectSettings.set_setting("gameplay/ui/auto_scale", true)
            show()
            var j := get_viewport()
            var k := mini(j.size.x, j.size.y)
            get_window().content_scale_factor = k / 1080.0


func _on_enable_pressed() -> void:
    ProjectSettings.set_setting("gameplay/ui/auto_scale", true)
    hide()


func _on_disabled_pressed() -> void:
    ProjectSettings.set_setting("gameplay/ui/auto_scale", false)
    hide()
    get_window().content_scale_factor = 1
