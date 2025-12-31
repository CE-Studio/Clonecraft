extends Panel


@onready var new_world := $backingpanel/HBoxContainer/newworld
@onready var world_folder := $backingpanel/HBoxContainer/worldfolder
@onready var back_button := $backingpanel/HBoxContainer/backbutton
@onready var world_list := $backingpanel/Panel/worldlist
@onready var world_list_container := $backingpanel/Panel/worldlist/Container


var packed_save_slot := preload("res://gui/SaveSlot.tscn")


func _ready():
	new_world.text = Translator.translate(&"gui.worlds.newworld")
	world_folder.text = Translator.translate(&"gui.worlds.worldfolder")
	world_folder.tooltip_text = ProjectSettings.globalize_path("user://saves/")
	back_button.text = Translator.translate(&"gui.generic.back")
	
	
func populateWorldList():
	for i in world_list_container.get_children():
		i.queue_free()
	world_list.show()
	for i in DirAccess.get_directories_at("user://saves/"):
		if FileAccess.file_exists("user://saves/" + i + "/ccworld.json"):
			var f = FileAccess.open("user://saves/" + i + "/ccworld.json", FileAccess.READ)
			var j = JSON.new()
			if j.parse(f.get_as_text()) == OK:
				var new_slot:SaveSlot = packed_save_slot.instantiate()
				world_list_container.add_child(new_slot)
				new_slot.populate(j.data, "user://saves/" + i)
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
