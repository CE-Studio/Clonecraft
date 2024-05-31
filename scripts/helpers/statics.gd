extends Object
class_name Statics

static func get_node(path:NodePath) -> Node:
	#This feels cheaty
	#why isn't get_node() available to static functions????????
	return Engine.get_main_loop().current_scene.get_node(path)


static func clamp_rotation(value:float, angle:float, pie:float) -> float:
	var h = 180 - abs(fmod(abs(value - angle), 360) - 180)
	print(value)
	print(h, ",")
	if h > pie:
		print("h")
		value = rotate_toward(value, angle, 100)
		print(value)
	print(value)
	return value
