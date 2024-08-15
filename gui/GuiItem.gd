extends Control
class_name GUIItem


signal clicked(target:GUIItem)


func assign(item:ItemManager.ItemStack) -> void:
	$label.text = str(item.count)
	if $label.text.length() > 3:
		$label.scale = Vector2(0.5, 0.5)
	else:
		$label.scale = Vector2(1, 1)
	if item.count == 1:
		$label.hide()
	else:
		$label.show()
	var m2d:TransformedMeshInstance2D = $transformedMeshInstance2d
	m2d.baseMesh = item.getMesh()
	m2d.mat = item.getMesh().surface_get_material(0)


func _on_button_pressed() -> void:
	clicked.emit(self)
