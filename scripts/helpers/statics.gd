extends Object
class_name Statics
## A class providing static functions or variables useful to all scripts.


## A static version of [method Node.get_node][br]
## Needs an [b]absolute[/b] path.
static func get_node(path:NodePath) -> Node:
	#This feels cheaty
	#why isn't get_node() available to static functions????????
	return Engine.get_main_loop().current_scene.get_node(path)


## A reimplementaion of [method @GDScript.range] to be [b]inclusive[/b] of the second parameter.
static func iRange(start:int, stop:int) -> Array:
	var dir
	if start >= stop:
		dir = -1
	else:
		dir = 1
	return range(start, stop + dir, dir)
