@tool
class_name PlantLayerEditor
extends Window


var _layer:BlockyPlantLayer
var optioncount:int
@onready var grid:GridContainer = $marginContainer/vBoxContainer/centerContainer/gridContainer


func setup(layer:BlockyPlantLayer) -> void:
	popup_centered()
	_layer = layer
	optioncount = _layer.blocks.size() - 1
	grid.columns = _layer.size.x
	var incr := 0
	for x in _layer.size.y:
		for y in _layer.size.x:
			var b := CycleButton.new()
			b.max_value = optioncount
			if incr < _layer.layer_data.size():
				b.value = _layer.layer_data[incr]
			grid.add_child(b)
			if Vector2i(x, y) == _layer.center:
				b.self_modulate = Color(1.0, 0.541, 0.477, 1.0)
			incr += 1
	min_size = $marginContainer.get_combined_minimum_size()


func _ready() -> void:
	if not Engine.is_editor_hint():
		var testobj = BlockyPlantLayer.new()
		testobj.size = Vector2i(9, 9)
		testobj.center = Vector2(4, 4)
		testobj.blocks.append(BlockyPlantBlock.new())
		testobj.blocks.append(BlockyPlantBlock.new())
		testobj.blocks.append(BlockyPlantBlock.new())
		setup(testobj)


func cancel() -> void:
	queue_free()


func accept() -> void:
	var outp:Array[int]
	for i in grid.get_children():
		if i is CycleButton:
			outp.append(i.value)
	assert(outp.size() == _layer.size.x * _layer.size.y)
	_layer.layer_data = outp
	queue_free()
