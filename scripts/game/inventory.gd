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
	var outp := {
		"space": space,
	}
	var compcont = []
	for i:ItemManager.ItemStack in container:
		compcont.append({
			"item": i.itemID,
			"count": i.count,
			"meta": i.metadata,
		})
	outp["container"] = compcont
	return outp


func restore(inp:Dictionary) -> bool:
	if !inp.has_all([
		"space",
		"container",
	]):
		return false
	space = inp["space"]
	for i in inp["container"]:
		if !i.has_all([
			"item",
			"count",
			"meta",
		]):
			return false
		var istack = ItemManager.ItemStack.new(i.item, i.count, i.meta)
		if !addItem(istack):
			return false
	return true


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


func getItemFromID(sitem:StringName) -> ItemManager.ItemStack:
	for i in container:
		if i.itemID == sitem:
			return i
	return null


func getItemFromStack(item:ItemManager.ItemStack, countMode := ANY) -> ItemManager.ItemStack:
	for i in container:
		if item.compare(i):
			match countMode:
				ANY:
					return i
				AT_LEAST:
					if i.count >= item.count:
						return i
				EXACTLY:
					if i.count == item.count:
						return i
				AT_MOST:
					if i.count <= item.count:
						return i
				_:
					return i
	return null


func containsItem(item:ItemManager.ItemStack, countMode := ANY) -> bool:
	for i in container:
		if item.compare(i):
			match countMode:
				ANY:
					return true
				AT_LEAST:
					return i.count >= item.count
				EXACTLY:
					return i.count == item.count
				AT_MOST:
					return i.count <= item.count
				_:
					return true
	return false
