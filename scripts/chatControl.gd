# TODO make this generally better
extends VBoxContainer
class_name Chat
## Manages displaying the chat.

## Very, very WIP.

## A refernce to the Chat singleton.[br]
## Static
static var instance:Chat
const _line := preload("res://scripts/helpers/chat_label.tscn")


func _ready() -> void:
    instance = self


## Display a line of text in the chat.[br]
## Static
static func pushText(text:String) -> void:
    if is_instance_valid(instance):
        var nline:Label = _line.instantiate()
        nline.text = text
        instance.add_child(nline)
