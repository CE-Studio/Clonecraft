@tool
extends Control


var ep:EditorPlugin
@onready var _odoc:Signal = ep.get_editor_interface().get_script_editor().get_current_editor().go_to_help
@onready var maintext := $TabContainer/Main


static func opentext(f:String) -> String:
    f = "res://addons/clonecraft_documentation/dat/content/" + f + ".txt"
    var ff = FileAccess.open(f, FileAccess.READ)
    var s = ff.get_as_text()
    ff.close()
    return s


func _ready():
    if ep != null:
        maintext.text = opentext("Index")


func _on_rich_text_label_meta_clicked(meta):
    var _m = meta.split(",")
    if _m[0] == "cla":
        _odoc.emit(_m[1])
    elif _m[0] == "doc":
        maintext.text = opentext(_m[1])
