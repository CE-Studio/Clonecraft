@abstract class_name EntityModel
extends Node3D


## How fast the player is currently moving
var speed:float
## The total distance the player has moved
var move_distance:float
## The total time the player has been in motion
var moveTime:float
## The total time the world has been loaded
var time:float
## The player's head direction
var look:Vector2
## The player's body direction, relative to the head.
var body_rotation:float


## Called every frame to update the animations
@abstract func animate(_delta:float) -> void


## Called to animate one-time actions, like placing or damage.
@abstract func animate_action(action:StringName) -> void


## Returns the first-person arm model. The default implementation should work for most cases.
func get_first_person_arm() -> Node3D:
	var h := get_children()
	for i in h:
		if i.name == "arm":
			for j in  i.get_children():
				if j.name == "handItem":
					return i
			var j := Node3D.new()
			j.name = "handItem"
			i.add_child(j)
			return i
	var j := Node3D.new()
	j.name = "arm"
	j.add_child(Node3D.new())
	j.get_child(0).name = "handItem"
	return j
