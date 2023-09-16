extends Node3D


# TODO loading in thread
func _ready():
    Translator._sinit()
    SettingManager._sinit()
    get_tree().change_scene_to_file("res://titlescreen/title.tscn")
