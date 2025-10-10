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
var consumption:int


signal content_changed


func sort() -> void:
	container.sort_custom(func(a, b): return a.count > b.count)


func save() -> Dictionary:
	var outp := {
		"space": space,
	}
	var compcont = []
	for i:ItemManager.ItemStack in container:
		compcont.append({
			"item": i.item_ID,
			"count": i.count,
			"meta": i.metadata,
		})
	outp["container"] = compcont
	return outp


func restore(inp:Dictionary, emit := true) -> bool:
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
		var meta:Dictionary[String, Variant] = {}
		for h in i.meta:
			meta[str(h)] = i.meta[h]
		var istack = ItemManager.ItemStack.new(i.item, i.count, meta)
		if !add_item(istack, emit):
			return false
	return true


func add_item(item:ItemManager.ItemStack, emit := true) -> bool:
	if (item.count + consumption) > space:
		return false
	consumption += item.count
	for i in container:
		if i.compare(item):
			i.count += item.count
			content_changed.emit()
			return true
	container.append(item)
	sort()
	if emit:
		content_changed.emit()
	return true


func add_item_partial(item:ItemManager.ItemStack) -> bool:
	var c := space - consumption
	if c < 1:
		return false
	if (item.count + consumption) > space:
		for i in container:
			if i.compare(item):
				if c > 0:
					i.count += c
					item.count -= c
					consumption += c
					return true
		var ni = item.copy()
		ni.count = c
		item.count -= c
		consumption += c
		container.append(ni)
		sort()
		content_changed.emit()
		return true
	consumption += item.count
	for i in container:
		if i.compare(item):
			i.count += item.count
			item.count = 0
			content_changed.emit()
			return true
	container.append(item.copy())
	item.count = 0
	sort()
	content_changed.emit()
	return true


func extract_item(item:ItemManager.ItemStack) -> bool:
	for i in container.size():
		if (item.compare(container[i])) && (item.count <= container[i].count):
			container[i].count -= item.count
			if container[i].count <= 0:
				container.remove_at(i)
			consumption -= item.count
			content_changed.emit()
			return true
	return false


func get_item_from_id(sitem:StringName) -> ItemManager.ItemStack:
	for i in container:
		if i.item_ID == sitem:
			return i
	return null


func get_item_from_stack(item:ItemManager.ItemStack, countMode := ANY, ignoreDamage := false, ignoreEnergy := false) -> ItemManager.ItemStack:
	for i in container:
		if item.compare(i, ignoreDamage, ignoreEnergy):
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


func extract_all() -> Array[ItemManager.ItemStack]:
	var out := container
	container = []
	consumption = 0
	content_changed.emit()
	return out


func contains_item(item:ItemManager.ItemStack, countMode := ANY) -> bool:
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
