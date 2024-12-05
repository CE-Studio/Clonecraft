extends Node3D
class_name HeldItem


func assign(item:ItemManager.ItemStack) -> void:
	if item == null:
		$sprite3d.hide()
		$meshInstance3d.hide()
		return
	var m := item.getModel()
	if m.is3D:
		$sprite3d.hide()
		$meshInstance3d.show()
		$meshInstance3d.mesh = m.mesh
	else:
		$sprite3d.show()
		$meshInstance3d.hide()
		$sprite3d.texture = m.texture
		$sprite3d.hframes = m.atlasSize.x
		$sprite3d.vframes = m.atlasSize.y
		$sprite3d.frame_coords = m.frame
