extends RefCounted
class_name Inventory
## A container for easily storing a collection of [ItemManager.ItemStack]s.


@export var space:int = 2624
var container:Array[ItemManager.ItemStack]
var consumption:int:
	set(_val):
		pass


func save() -> Dictionary:
	return {}


func load(inp:Dictionary) -> bool:
	return false


func addItem(item:ItemManager.ItemStack) -> bool:
	if (item.count + consumption) > space:
		return false
	consumption += item.count
	for i in container:
		if i.compare(item):
			i.count += item.count
			return true
	container.append(item)
	return true


func extractItem(item:ItemManager.ItemStack) -> bool:
	return false


func containsItem(item:ItemManager.ItemStack, strict := true) -> bool:
	for i in container:
		if item.compare(i):
			if strict:
				return i.count == item.count
			return true
	return false
