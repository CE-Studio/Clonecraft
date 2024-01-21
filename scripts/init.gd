extends Node3D


@onready var bar := $control/vBoxContainer/progressBar
@onready var label := $control/vBoxContainer/label
var step := 0
var pckmods:Array[String] = []


func _ready() -> void:
    label.text = "Init..."
    bar.value = 0
    bar.max_value = 3
    
    
func _process(_delta):
    match step:
        0:
            label.text = "Loading..."
        1:
            label.text = "Init translation..."
            Translator._sinit()
        2:
            label.text = "Init settings..."
            SettingManager._sinit()
        _:
            var substep = step - 3
            if substep >= pckmods.size():
                get_tree().change_scene_to_file("res://titlescreen/title.tscn")
            else:
                ProjectSettings.load_resource_pack("user://mods/" + pckmods[substep] + ".pck")
    bar.value = step
    step += 1
