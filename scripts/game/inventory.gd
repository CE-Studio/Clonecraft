extends RefCounted
class_name Inventory
## A container for easily storing a collection of [ItemManager.ItemStack]s.


@export var space:int = 2624
var container:Array[ItemManager.ItemStack]
var consumption:int
	set(_val):
		pass


func save() -> Dictionary:
	pass


func load(inp:Dictionary) -> bool:
	pass


func addItem(item:ItemManager.ItemStack) -> bool:
	pass


func extractItem(item:ItemManager.ItemStack) -> bool:
	pass


func containsItem(item:ItemManager.ItemStack) -> bool:
	pass