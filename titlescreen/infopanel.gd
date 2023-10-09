extends Control

@onready var _vp := get_viewport()
var pos := 150.0

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if (event.position.x < 650) && (event.position.y > (_vp.get_visible_rect().size.y - 150)):
            pos = 0
        else:
            pos = 150


func _process(delta: float) -> void:
    position.y = lerpf(position.y, pos, 10 * delta)
