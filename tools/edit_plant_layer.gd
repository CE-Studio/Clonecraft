extends Window


var _layer:BlockyPlantLayer


func setup(layer:BlockyPlantLayer) -> void:
	popup()
	_layer = layer
	var grid:GridContainer = $marginContainer/vBoxContainer/gridContainer
	grid.columns = _layer.size.x
	for x in _layer.size.x:
		for y in _layer.size.y:
			grid.add_child(Button.new())


func _ready() -> void:
	if not Engine.is_editor_hint():
		var testobj = BlockyPlantLayer.new()
		testobj.size = Vector2i(10, 10)
		setup(testobj)
