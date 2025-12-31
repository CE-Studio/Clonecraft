extends PanelContainer


var gui_item:PackedScene = preload("res://gui/GuiItem.tscn")
@onready var fill_bar:ProgressBar = $vBoxContainer/fillBar
@onready var grid:GridContainer = $vBoxContainer/scrollContainer/hBoxContainer/gridContainer
var inv:Inventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup.call_deferred()
	redraw.call_deferred()
	inv.content_changed.connect(redraw)


func setup() -> void:
	var p = get_parent().get_parent()
	if p is InventoryTabs:
		var i = get_parent().get_index()
		p.set_tab_icon(i, preload("res://gui/invico.png"))
		p.set_tab_title(i, "")
		p.set_tab_tooltip(i, Translator.translate(&"clonecraft.inventory.chest"))


func pick(i:GUIItem) -> void:
	if not InventoryLayer.holding:
		InventoryLayer.hold(i.item, inv)
	else:
		InventoryLayer.drop_into(inv)


func redraw() -> void:
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
	InventoryLayer.drop_into(inv)
