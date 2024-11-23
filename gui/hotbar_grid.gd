extends GridContainer


var guii:PackedScene = preload("res://gui/GuiItem.tscn")
var guib:PackedScene = preload("res://gui/GuiItemBlank.tscn")


func _ready() -> void:
	redraw()


func redraw() -> void:
	for i in get_children():
		i.queue_free()
	var id = 0
	for i in WorldControl.instance._p.hotbarItems:
		var gi
		if i == null:
			gi = guib.instantiate()
		else:
			gi = guii.instantiate()
			gi.assign(i)
		gi.slotID = id
		add_child(gi)
		id += 1
