extends PanelContainer


var gui_item:PackedScene = preload("res://gui/GuiItem.tscn")
@onready var fill_bar:ProgressBar = $vBoxContainer/fillBar
@onready var grid:GridContainer = $vBoxContainer/scrollContainer/panelContainer/hBoxContainer/gridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup.call_deferred()
	redraw.call_deferred()
	WorldControl.instance._player.inventory.content_changed.connect(redraw)


func setup() -> void:
	var p = get_parent()
	if p is InventoryTabs:
		var i = get_index()
		p.set_tab_icon(i, preload("res://gui/invico.png"))
		p.set_tab_title(i, "")
		p.set_tab_tooltip(i, Translator.translate(&"gameplay.inventory.primary"))


func pick(i:GUIItem) -> void:
	if not InventoryLayer.holding:
		InventoryLayer.hold(i.item, WorldControl.instance._player.inventory)
	else:
		InventoryLayer.drop_into(WorldControl.instance._player.inventory)


func redraw() -> void:
	var inv := WorldControl.instance._player.inventory
	fill_bar.max_value = inv.space
	fill_bar.value = inv.consumption
	for i in grid.get_children():
		i.queue_free()
	for i in inv.container:
		var ngi:GUIItem = gui_item.instantiate()
		ngi.clicked.connect(pick)
		grid.add_child(ngi)
		ngi.assign(i)


func _on_button_pressed() -> void:
	InventoryLayer.drop_into(WorldControl.instance._player.inventory)
