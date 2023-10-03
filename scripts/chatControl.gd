# TODO make this generally better
extends VBoxContainer
class_name Chat


static var instance:Chat
const _line := preload("res://scripts/helpers/chat_label.tscn")


func _ready():
    instance = self


static func pushText(text:String):
    if is_instance_valid(instance):
        var nline:Label = _line.instantiate()
        nline.text = text
        instance.add_child(nline)
