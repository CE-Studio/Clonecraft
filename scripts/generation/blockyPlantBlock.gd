class_name BlockyPlantBlock
extends Resource


@export var types_and_chances:Dictionary[StringName, float] = {
	&"clonecraft:air": 100.0
}


var not_normalized := true


func normalize():
	not_normalized = false
	var total:float = 0
	var count:float = types_and_chances.size()
	for i in types_and_chances:
		types_and_chances[i] = maxf(0, types_and_chances[i])
		total += types_and_chances[i]
	if total == 0:
		for i in types_and_chances:
			types_and_chances[i] = 100.0 / count
	else:
		for i in types_and_chances:
			types_and_chances[i] = (types_and_chances[i] / total) * 100.0


func generate(rng:RandomNumberGenerator) -> StringName:
	if not_normalized:
		normalize()
	var value := rng.randf_range(0, 100)
	var total := 0.0
	if types_and_chances.size() == 0:
		return &"clonecraft:air"
	for i in types_and_chances:
		total += types_and_chances[i]
		if total >= value:
			return i
	return types_and_chances.keys()[rng.randi_range(0, types_and_chances.size())]
	
