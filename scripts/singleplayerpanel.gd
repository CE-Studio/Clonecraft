extends Panel


@onready var newworld := $backingpanel/HBoxContainer/newworld
@onready var worldfolder := $backingpanel/HBoxContainer/worldfolder
@onready var backbutton := $backingpanel/HBoxContainer/backbutton


func _ready():
    newworld.text = Translator.translate(&"gui.worlds.newworld")
    worldfolder.text = Translator.translate(&"gui.worlds.worldfolder")
    worldfolder.tooltip_text = ProjectSettings.globalize_path("user://saves/")
    backbutton.text = Translator.translate(&"gui.generic.back")


func _on_newworld_pressed():
    pass # Replace with function body.


func _on_worldfolder_pressed():
    OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://saves/"))


func _on_backbutton_pressed():
    pass # Replace with function body.
