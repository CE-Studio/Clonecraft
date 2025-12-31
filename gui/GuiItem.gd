extends Control
class_name GUIItem


signal clicked(target:GUIItem)
signal pressed
signal slotPressed(slot:int)


var slotID:int = 0
var item:ItemManager.ItemStack


func assign(_item:ItemManager.ItemStack) -> void:
	item = _item
	$label.mouse_filter = mouse_filter
	$button.mouse_filter = mouse_filter
	$label.text = str(item.count)
	if $label.text.length() > 3:
		$label.scale = Vector2(0.5, 0.5)
	else:
		$label.scale = Vector2(1, 1)
	if item.count == 1:
		$label.hide()
	else:
		$label.show()
	var im := item.get_model()
	if im.is_3D:
		var m2d:TransformedMeshInstance2D = $transformedMeshInstance2d
		m2d.base_mesh = im.mesh
		if im.mesh.get_surface_count() != 0:
			m2d.mat = im.mesh.surface_get_material(0)
	else:
		var s:Sprite2D = $sprite2d
		s.texture = im.texture
		s.hframes = im.atlas_size.x
		s.vframes = im.atlas_size.y
		s.frame_coords = im.frame
	var n = item.get_item().name
	if n != "":
		$button.tooltip_text = Translator.translate(n)
	else:
		$button.tooltip_text = item.item_ID


func _on_button_pressed() -> void:
	clicked.emit(self)
	pressed.emit()
	slotPressed.emit(slotID)
