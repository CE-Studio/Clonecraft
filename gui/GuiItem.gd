extends Control
class_name GUIItem


func assign(item:ItemManager.ItemStack) -> void:
	$label.text = str(item.count)
	if item.count == 1:
		$label.hide()
	else:
		$label.show()
	var m2d:TransformedMeshInstance2D = $transformedMeshInstance2d
	m2d.baseMesh = item.getMesh()
	m2d.mat = item.getMesh().surface_get_material(0)
