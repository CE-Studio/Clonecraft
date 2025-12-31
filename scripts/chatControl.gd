# TODO make this generally better
extends VBoxContainer
class_name Chat
## Manages displaying the chat.

## Very, very WIP.

## A reference to the Chat singleton.[br]
## Static
static var instance:Chat
const _line := preload("res://scripts/helpers/chat_label.tscn")


@onready var vbox:VBoxContainer = $vBoxContainer
@onready var input_line:LineEdit = $inpline


func _ready() -> void:
	instance = self
	input_line.visible = false
	input_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
func _input(event):
	if event.is_action_pressed("game_chat"):
		if not input_line.visible:
			get_viewport().set_input_as_handled()
			input_line.visible = true
			input_line.mouse_filter = Control.MOUSE_FILTER_STOP
		input_line.grab_focus()
	if event.is_action_pressed("ui_cancel"):
		if input_line.visible:
			input_line.visible = false
			get_viewport().set_input_as_handled()


## Display a line of text in the chat.[br]
## Static
static func push_text(text:String) -> void:
	if is_instance_valid(instance):
		var new_line:Label = _line.instantiate()
		new_line.text = text
		instance.vbox.add_child(new_line)


func _on_inpline_text_submitted(new_text:String):
	input_line.visible = false
	input_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if new_text == "":
		return
	if new_text[0] == "/":
		CMDprocessor._called_by_player = true
		Chat.push_text(str(CMDprocessor.run(new_text.erase(0, 1))))
		CMDprocessor._called_by_player = false
		return
	Chat.push_text("[" + WorldControl.local_username + "] " + new_text)
	input_line.text = ""
