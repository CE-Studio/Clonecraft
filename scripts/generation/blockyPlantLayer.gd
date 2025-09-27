@tool
class_name BlockyPlantLayer
extends Resource


@export_tool_button("Edit") var edit := _edit


func _edit() -> void:
	if Engine.is_editor_hint():
		pass


@export var size:Vector2i
@export var center:Vector2i
@export var blocks:Array[BlockyPlantBlock]
@export_storage var layerdata:Array[int]
