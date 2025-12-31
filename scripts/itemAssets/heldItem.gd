extends Node3D
class_name HeldItem


func assign(item:ItemManager.ItemStack) -> void:
	if item == null:
		$sprite3d.hide()
		$meshInstance3d.hide()
		return
	var m := item.get_model()
	if m.is_3D:
		$sprite3d.hide()
		$meshInstance3d.show()
		$meshInstance3d.mesh = m.mesh
	else:
		$sprite3d.show()
		$meshInstance3d.hide()
		$sprite3d.texture = m.texture
		$sprite3d.hframes = m.atlas_size.x
		$sprite3d.vframes = m.atlas_size.y
		$sprite3d.frame_coords = m.frame
