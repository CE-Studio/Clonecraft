# TODO make this generally better
extends VBoxContainer
class_name Chat
## Manages displaying the chat.

## Very, very WIP.

## A refernce to the Chat singleton.[br]
## Static
static var instance:Chat
const _line := preload("res://scripts/helpers/chat_label.tscn")


@onready var inpline:LineEdit = $inpline


func _ready() -> void:
	instance = self
	inpline.visible = false
	inpline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
func _input(event):
	if event.is_action_pressed("game_chat"):
		if not inpline.visible:
			get_viewport().set_input_as_handled()
			inpline.text = ""
			inpline.visible = true
			inpline.mouse_filter = Control.MOUSE_FILTER_STOP
			inpline.grab_focus()


## Display a line of text in the chat.[br]
## Static
static func pushText(text:String) -> void:
	if is_instance_valid(instance):
		var nline:Label = _line.instantiate()
		nline.text = text
		instance.add_child(nline)


func _on_inpline_text_submitted(new_text):
	pushText(new_text)
	inpline.visible = false
	inpline.mouse_filter = Control.MOUSE_FILTER_IGNORE
