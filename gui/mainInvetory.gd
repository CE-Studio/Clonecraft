extends PanelContainer


var guii:PackedScene = preload("res://gui/GuiItem.tscn")
@onready var fillbar:ProgressBar = $vBoxContainer/fillBar
@onready var grid:GridContainer = $vBoxContainer/scrollContainer/gridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p = get_parent()
	var i = get_index()
	p.set_tab_icon(i, preload("res://textures/ok.png"))
	p.set_tab_title(i, "")
	p.set_tab_tooltip(i, Translator.translate(&"gameplay.inventory.primary"))
	redraw.call_deferred()


func redraw() -> void:
	var inv := WorldControl.instance._p.inventory
	fillbar.max_value = inv.space
	fillbar.value = inv.consumption
	for i in grid.get_children():
		i.queue_free()
	for i in inv.container:
		var ngi:GUIItem = guii.instantiate()
		grid.add_child(ngi)
		ngi.assign(i)
