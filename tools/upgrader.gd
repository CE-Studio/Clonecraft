extends Node3D


func _on_button_pressed() -> void:
	$button.disabled = true
	#var size:int = $voxelViewer.view_distance
	var size:int = 16
	var oldstream:VoxelStreamRegionFiles = $voxelTerrain.stream
	var newstream:VoxelStream = VoxelStreamRegionFiles.new()
	newstream.directory = "user://fixed/"
	assert(oldstream.get_block_size() == newstream.get_block_size())
	var bsize := oldstream.get_block_size()
	var x := -size
	while x < size:
		var y := -size
		while y < size:
			var z := -size
			while z < size:
				var buf := VoxelBuffer.new()
				buf.create(bsize.x, bsize.y, bsize.z)
				var rx := x
				var ry := y
				var rz := z
				if rx < 0:
					rx -= 1
				if ry < 0:
					ry -= 1
				if rz < 0:
					rz -= 1
				var stat = oldstream.load_voxel_block(buf, Vector3i(rx, ry, rz), 0)
				if stat == VoxelStream.RESULT_BLOCK_FOUND:
					newstream.save_voxel_block(buf, Vector3i(x, y, z), 0)
				#z += bsize.z
				z += 1
			#y += bsize.y
			y += 1
		#x += bsize.x
		x += 1
	$voxelTerrain.stream = newstream
	newstream.flush()
	
