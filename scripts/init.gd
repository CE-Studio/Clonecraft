extends Node3D


@onready var bar := $control/vBoxContainer/progressBar
@onready var label := $control/vBoxContainer/label
var step := 0
var pckmods:Array = []


func _ready() -> void:
    label.text = "Init..."
    bar.value = 0
    bar.max_value = 4
    
    
func _process(_delta):
    match step:
        0:
            label.text = "Checking mod config..."
            if FileAccess.file_exists("user://active_mods.json"):
                var f = FileAccess.open("user://active_mods.json", FileAccess.READ)
                var content = f.get_as_text()
                f.close()
                var json = JSON.new()
                var error = json.parse(content)
                if (error == OK) && (json.data is Array):
                    pckmods = json.data
                    bar.max_value += pckmods.size()
                else:
                    f = FileAccess.open("user://active_mods.json", FileAccess.WRITE)
                    f.store_string("[]")
                    f.close()
            else:
                var f = FileAccess.open("user://active_mods.json", FileAccess.WRITE)
                f.store_string("[]")
                f.close()
        1:
            label.text = "Checking folders..."
            if not DirAccess.dir_exists_absolute("user://mods"):
                DirAccess.make_dir_absolute("user://mods")
            if not DirAccess.dir_exists_absolute("user://saves"):
                DirAccess.make_dir_absolute("user://saves")
            if not DirAccess.dir_exists_absolute("user://screenshots"):
                DirAccess.make_dir_absolute("user://screenshots")
        2:
            label.text = "Init translation..."
            Translator._sinit()
        3:
            label.text = "Init settings..."
            SettingManager._sinit()
        _:
            var substep = step - 4
            if substep >= pckmods.size():
                get_tree().change_scene_to_file("res://titlescreen/title.tscn")
            else:
                if pckmods[substep] is String:
                    var nextpck:String = "user://mods/" + pckmods[substep] + ".pck"
                    if FileAccess.file_exists(nextpck):
                        ProjectSettings.load_resource_pack(nextpck)
                    else:
                        print("Can't find mod: " + nextpck)
    bar.value = step
    step += 1
