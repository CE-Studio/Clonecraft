extends Button
class_name ModPckItem
## Used to display mods in the ModPicker.


var list_off:VBoxContainer
var list_on:VBoxContainer
var on_button:Button
var off_button:Button
var mod_name:StringName


func init(off:VBoxContainer, on:VBoxContainer, state:bool, _mod_name:StringName):
	on_button = $">"
	off_button = $"<"
	list_off = off
	list_on = on
	off.add_child(self)
	if state:
		_on_on_pressed()
	else:
		_on_off_pressed()
	mod_name = _mod_name
	text = "  " + _mod_name + "  "



func _on_off_pressed():
	reparent(list_off, false)
	off_button.disabled = true
	on_button.disabled = false


func _on_on_pressed():
	reparent(list_on, false)
	off_button.disabled = false
	on_button.disabled = true


func _on_pressed():
	if on_button.disabled:
		_on_off_pressed()
	else:
		_on_on_pressed()
