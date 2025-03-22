extends CharacterBody3D
class_name Entity


var TERMINAL_VELOCITY:float = ProjectSettings.get_setting("gameplay/physics/terminal_velocity")
var GRAVITY:float = ProjectSettings.get_setting("physics/3d/default_gravity")

var sleeping := true

## Defines some basic abillities of the entity.[br]
## Scale is a multiplier, size is absolute.
var abilities := {
	"allowFlight":false,
	"isFlying":false,
	"allowBuild":false,
	"endlessInventory":false,
	"allowPickup":false,
	"immortal":false,
	"health": 20.0,
	"oxygen": 20.0,
	"food": 20.0,
	"saturation": 20.0,
	"scale":{
		"uniform":1.0,
		"x":1.0,
		"y":1.0,
		"z":1.0,
		"speed":1.0,
		"jump":1.0,
		"range":1.0,
		"reach":1.0,
		"inventory":1.0,
		"health":1.0,
		"oxygen": 1.0,
		"fallDamage":1.0,
		"food": 1.0,
		"saturation": 1.0,
	},
	"size":{
		"x":1.0,
		"y":1.0,
		"z":1.0,
		"speed":5.0,
		"jump":8.0,
		"reach":0.0,
		"inventory":0.0,
		"health":20.0,
		"oxygen": 20.0,
		"fallDamage":4.0,
		"food": 20.0,
		"saturation": 20.0,
	},
}


func get_aabb() -> AABB:
	var aabb := AABB()
	var sv3 := Vector3(
		abilities["size"]["x"],
		abilities["size"]["y"],
		abilities["size"]["z"]
	)
	var scv3 := Vector3(
		abilities["scale"]["x"],
		abilities["scale"]["y"],
		abilities["scale"]["z"]
	)
	for i in get_children():
		if i is CollisionShape3D:
			var shape = i.shape
			if shape is BoxShape3D:
				aabb.size = shape.size * sv3 * scv3
	aabb.position = global_position - (aabb.size / 2.0)
	return aabb
	


func save() -> Dictionary:
	return {
		"abilities": abilities,
		"posx": position.x,
		"posy": position.y,
		"posz": position.z,
	}
	
	
func restore(dict:Dictionary) -> bool:
	if dict.has_all([
		"abilities",
		"posx",
		"posy",
		"posz",
	]):
		abilities = dict["abilities"]
		position.x = dict["posx"]
		position.y = dict["posy"]
		position.z = dict["posz"]
		updateAbilities()
		return true
	return false
	
	
func updateAbilities() -> void:
	scale.x = (abilities["size"]["x"] * abilities["scale"]["x"]) * abilities["scale"]["uniform"]
	scale.y = (abilities["size"]["y"] * abilities["scale"]["y"]) * abilities["scale"]["uniform"]
	scale.z = (abilities["size"]["z"] * abilities["scale"]["x"]) * abilities["scale"]["uniform"]
	

func _settingsChanged() -> void:
	TERMINAL_VELOCITY = ProjectSettings.get_setting("gameplay/physics/terminal_velocity")
	GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")


func _movement_process(_delta:float) -> void:
	pass


func getScaled(ability:String) -> float:
	var v := 0.0
	v = abilities.size
	v *= abilities.scale[ability]
	v *= abilities.scale.uniform
	return v


func damage(ammount:float) -> void:
	if not abilities.immortal:
		abilities.health -= ammount
		animateDamage(ammount)
	if abilities.health <= 0:
		die()


func heal(ammount:float) -> bool:
	var mh := getScaled("health")
	abilities.health = clampf(abilities.health + ammount, 0, mh)
	return abilities.health == mh


func die() -> void:
	pass


func animateDamage(ammount:float) -> void:
	pass


func _physics_process(delta:float) -> void:
	if sleeping:
		return
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	_movement_process(delta)

	move_and_slide()
