@tool
class_name BlockyPlantLayer
extends Resource


@export_tool_button("Edit") var edit := _edit


func _edit() -> void:
	if Engine.is_editor_hint():
		var editwindow:PlantLayerEditor = load("uid://p305vt6on8gu").instantiate()
		EditorInterface.popup_dialog(editwindow)
		editwindow.setup(self)


@export var size:Vector2i = Vector2i.ONE
@export var center:Vector2i = Vector2i.ZERO
@export_range(0, 100, 0.001) var bifurcate_chance:float = 0
@export var min_count:int = 1
@export var max_count:int = 3
@export var drift_range:Vector2i = Vector2i.ZERO
@export var blocks:Array[BlockyPlantBlock]
@export_storage var layerdata:Array[int]


func generate(rng:RandomNumberGenerator) -> Dictionary[StringName, Variant]:
	var dict:Dictionary[StringName, Variant] = {
		&"size": Vector2i(size),
		&"center": Vector2i(center),
		&"data": [],
	}
	for i in layerdata:
		dict.data.append(blocks[i].generate(rng))
	return dict
