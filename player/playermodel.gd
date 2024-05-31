extends Node3D
class_name PlayerModel


## How fast the player is currently moving
var speed:float
## The total distance the player has moved
var moveDistance:float
## The total time the player has been in motion
var moveTime:float
## The total time the world has been loaded
var time:float
## The player's head direction
var look:Vector2
## The player's body direction, relative to the head.
var bodyRotation:float


## Called every frame to update the animations
func animate() -> void:
	pass


## Returns the first-person arm model. The default implementation should work for most cases.
func getFPArm() -> Node3D:
	var h := get_children()
	for i in h:
		if i.name == "arm":
			return i
	var j := Node3D.new()
	j.name = "arm"
	j.add_child(Node3D.new())
	j.get_child(0).name = "handItem"
	return j
