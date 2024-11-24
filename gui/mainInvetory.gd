extends PanelContainer


var guii:PackedScene = preload("res://gui/GuiItem.tscn")
@onready var fillbar:ProgressBar = $vBoxContainer/fillBar
@onready var grid:GridContainer = $vBoxContainer/scrollContainer/hBoxContainer/gridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p = get_parent()
	if p is InventoryTabs:
		var i = get_index()
		p.set_tab_icon(i, preload("res://textures/ok.png"))
		p.set_tab_title(i, "")
		p.set_tab_tooltip(i, Translator.translate(&"gameplay.inventory.primary"))
	redraw.call_deferred()
	WorldControl.instance._p.inventory.contentChanged.connect(redraw)


func pick(i:GUIItem) -> void:
	if not InventoryLayer.holding:
		InventoryLayer.hold(i.item, WorldControl.instance._p.inventory)
	else:
		InventoryLayer.dropInto(WorldControl.instance._p.inventory)


func redraw() -> void:
	var inv := WorldControl.instance._p.inventory
	fillbar.max_value = inv.space
	fillbar.value = inv.consumption
	for i in grid.get_children():
		i.queue_free()
	for i in inv.container:
		var ngi:GUIItem = guii.instantiate()
		ngi.clicked.connect(pick)
		grid.add_child(ngi)
		ngi.assign(i)


func _on_button_pressed() -> void:
	InventoryLayer.dropInto(WorldControl.instance._p.inventory)
