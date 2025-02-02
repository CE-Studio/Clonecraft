extends TabContainer
class_name InventoryTabs


static var tabs:Array[PackedScene] = []
static var contextualTabs:Array[PackedScene] = []
static var contextualConditions:Array[Callable] = []
static var tempTabs:Array[Control] = []


static func registerTab(tab:PackedScene) -> void:
	tabs.append(tab)


static func registerTempTab(tab:Control) -> void:
	tempTabs.append(tab)


static func registerContextualTab(tab:PackedScene, condition:Callable) -> void:
	contextualTabs.append(tab)
	contextualConditions.append(condition)


func _ready() -> void:
	for i in tabs:
		add_child(i.instantiate())
	assert(contextualTabs.size() == contextualConditions.size(), "Imbalanced tabs and conditions")
	for i in contextualTabs.size():
		if contextualConditions[i].call():
			add_child(contextualTabs[i].instantiate())
			current_tab = get_child_count() - 1
	for i in tempTabs:
		add_child(i)
		current_tab = get_child_count() - 1
	tempTabs = []
