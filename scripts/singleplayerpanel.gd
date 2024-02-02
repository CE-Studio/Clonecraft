extends Panel


@onready var newworld := $backingpanel/HBoxContainer/newworld
@onready var worldfolder := $backingpanel/HBoxContainer/worldfolder
@onready var backbutton := $backingpanel/HBoxContainer/backbutton
@onready var worldlist := $backingpanel/Panel/worldlist
@onready var worldlistcontainer := $backingpanel/Panel/worldlist/Container


var packedsaveslot := preload("res://gui/SaveSlot.tscn")


func _ready():
    newworld.text = Translator.translate(&"gui.worlds.newworld")
    worldfolder.text = Translator.translate(&"gui.worlds.worldfolder")
    worldfolder.tooltip_text = ProjectSettings.globalize_path("user://saves/")
    backbutton.text = Translator.translate(&"gui.generic.back")
    
    
func populateWorldList():
    for i in worldlistcontainer.get_children():
        i.queue_free()
    worldlist.show()
    for i in DirAccess.get_directories_at("user://saves/"):
        if FileAccess.file_exists("user://saves/" + i + "/ccworld.json"):
            var f = FileAccess.open("user://saves/" + i + "/ccworld.json", FileAccess.READ)
            var j = JSON.new()
            if j.parse(f.get_as_text()) == OK:
                var newslot:SaveSlot = packedsaveslot.instantiate()
                worldlistcontainer.add_child(newslot)
                newslot.populate(j.data, "user://saves/" + i)
            f.close()


func _on_newworld_pressed():
    pass # Replace with function body.


func _on_worldfolder_pressed():
    OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://saves/"))


func _on_backbutton_pressed():
    hide()


func _on_visibility_changed():
    if visible:
        populateWorldList()
