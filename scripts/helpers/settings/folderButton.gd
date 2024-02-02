extends Button
class_name SettingFolderButton

var iname:StringName
var content: Array


func init(i) -> void:
	iname = i["name"]
	text = Translator.translate(iname)
	content = i["content"]


func _on_pressed():
	SettingManager.spawnMenu(content)
