extends Button
class_name ModPckItem
## Used to display mods in the modpicker.


var loff:VBoxContainer
var lon:VBoxContainer
var onbutton:Button
var offbutton:Button
var modname:StringName


func init(off:VBoxContainer, on:VBoxContainer, state:bool, modn:StringName):
	onbutton = $">"
	offbutton = $"<"
	loff = off
	lon = on
	off.add_child(self)
	if state:
		_on_on_pressed()
	else:
		_on_off_pressed()
	modname = modn
	text = "  " + modn + "  "



func _on_off_pressed():
	reparent(loff, false)
	offbutton.disabled = true
	onbutton.disabled = false


func _on_on_pressed():
	reparent(lon, false)
	offbutton.disabled = false
	onbutton.disabled = true


func _on_pressed():
	if onbutton.disabled:
		_on_off_pressed()
	else:
		_on_on_pressed()
