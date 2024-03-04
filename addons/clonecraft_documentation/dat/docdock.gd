@tool
extends Control


var ep:EditorPlugin
var maintext
var _odoc


static func opentext(f:String) -> String:
	var h = "res://addons/clonecraft_documentation/dat/content/" + f + ".txt"
	var ff = FileAccess.open(h, FileAccess.READ)
	var s = ff.get_as_text()
	ff.close()
	print(f)
	return s


func ready():
	if ep != null:
		maintext = $TabContainer/Main
		maintext.text = opentext("Index")


func _on_rich_text_label_meta_clicked(meta):
	if _odoc == null:
		_odoc = ep.get_editor_interface().get_script_editor().get_current_editor().go_to_help
	var _m = meta.split(",")
	if _m[0] == "cla":
		_odoc.emit(_m[1])
	elif _m[0] == "doc":
		maintext.text = opentext(_m[1])
