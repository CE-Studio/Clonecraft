extends RefCounted
class_name Inventory
## A container for easily storing a collection of [ItemManager.ItemStack]s.


enum {
	ANY,
	AT_LEAST,
	EXACTLY,
	AT_MOST
}


@export var space:int = 2624
var container:Array[ItemManager.ItemStack]
var consumption:int:
	set(_val):
		pass


signal contentChanged


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
			contentChanged.emit()
			return true
	container.append(item)
	contentChanged.emit()
	return true


func extractItem(item:ItemManager.ItemStack) -> bool:
	for i in container.size():
		if (item.compare(container[i])) && (item.count <= container[i].count):
			container[i].count -= item.count
			if container[i].count <= 0:
				container.remove_at(i)
			contentChanged.emit()
			return true
	return false


func containsItem(item:ItemManager.ItemStack, countMode := ANY) -> bool:
	for i in container:
		if item.compare(i):
			match countMode:
				_:
					return true
				ANY:
					return true
				AT_LEAST:
					return i.count >= item.count
				EXACTLY:
					return i.count == item.count
				AT_MOST:
					return i.count <= item.count
	return false
