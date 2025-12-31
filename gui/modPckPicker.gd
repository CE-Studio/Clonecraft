extends HBoxContainer


func _ready():
	var f := FileAccess.open("user://active_mods.json", FileAccess.READ)
	var load_list:Array = JSON.parse_string(f.get_as_text())
	f.close()
	for i in DirAccess.get_files_at("user://mods/"):
		if i.ends_with(".pck"):
			var j:ModPckItem = preload("res://gui/modPckItem.tscn").instantiate()
			var l := i.get_basename()
			j.init($offList, $onList, l in load_list, l)


func save():
	var h:Array[String] = []
	for i in $onList.get_children():
		if i is ModPckItem:
			h.append(i.mod_name)
	var f := FileAccess.open("user://active_mods.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(h))
	f.close()
