@abstract class_name Entity
extends CharacterBody3D


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
		update_abilities()
		return true
	return false
	
	
func update_abilities() -> void:
	scale.x = (abilities["size"]["x"] * abilities["scale"]["x"]) * abilities["scale"]["uniform"]
	scale.y = (abilities["size"]["y"] * abilities["scale"]["y"]) * abilities["scale"]["uniform"]
	scale.z = (abilities["size"]["z"] * abilities["scale"]["x"]) * abilities["scale"]["uniform"]
	

func _settings_changed() -> void:
	TERMINAL_VELOCITY = ProjectSettings.get_setting("gameplay/physics/terminal_velocity")
	GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")


@abstract func _movement_process(_delta:float) -> void


func get_scaled(ability:String) -> float:
	var v := 0.0
	v = abilities.size[ability]
	v *= abilities.scale[ability]
	v *= abilities.scale.uniform
	return v


func damage(amount:float) -> void:
	if not abilities.immortal:
		abilities.health -= amount
		animate_damage(amount)
	if abilities.health <= 0:
		die()


func heal(amount:float) -> bool:
	var mh := get_scaled("health")
	abilities.health = clampf(abilities.health + amount, 0, mh)
	return abilities.health == mh


@abstract func die() -> void


@abstract func animate_damage(amount:float) -> void


func _physics_process(delta:float) -> void:
	if sleeping:
		return
	if not is_on_floor():
		velocity.y = max(velocity.y - (GRAVITY * delta), -TERMINAL_VELOCITY)

	_movement_process(delta)

	move_and_slide()


func interact(event:InputEvent) -> bool:
	if event.is_action_pressed("game_break"):
		damage(1)
		return true
	if event.is_action("game_place") or event.is_action("game_break"):
		return true
	return false
