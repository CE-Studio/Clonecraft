extends MarginContainer
class_name ItemTooltip


var item:ItemManager.ItemStack
var text:String
var pondertext:String
var pondertime := 0.0
@onready var ponder:RichTextLabel = $ItemTooltip/ponder


func _ready() -> void:
	if item.metadata.has(&"name"):
		$ItemTooltip/name.text = item.metadata[&"name"]
	else:
		$ItemTooltip/name.text = text
	
	if item.metadata.has(&"lore"):
		$ItemTooltip/lore.show()
		$ItemTooltip/lore.text = item.metadata[&"lore"]
	
	if item.metadata.has_all([&"energy", &"energyMax"]):
		$ItemTooltip/energy.show()
		$ItemTooltip/energy.value = item.metadata[&"energy"]
		$ItemTooltip/energy.max_value = item.metadata[&"energyMax"]
	
	
	if item.metadata.has_all([&"damage", &"damageMax"]):
		$ItemTooltip/damage.show()
		$ItemTooltip/damage.text = str(item.metadata[&"damage"]) + "/" + str(item.metadata[&"damageMax"]) + " &&damage&&"
	
	
	$ItemTooltip/id.text = item.item_ID
	
	
	if item.getItem().ponderScene != &"":
		var filler:String = ""
		for i in InputMap.action_get_events("game_ponder"):
			filler += " " + i.as_text()
		filler = filler.strip_edges()
		filler = "[/color][color=#ffffff]" + filler + "[/color][color=#aaaaaa]"
		pondertext = "[color=#aaaaaa]" + (Translator.translate(&"gui.gameplay.ponder") % [filler]) + "[/color]"
		ponder.text = pondertext
		ponder.show()
	
	
	$ItemTooltip/modname.text = item.item_ID.split(":")[0].capitalize()
	
	if ProjectSettings.get_setting("gameplay/debug/show_item_metadata"):
		var s := "{"
		for i in item.metadata:
			s += "\n  " + i + " : " + str(item.metadata[i]) + ","
		s += "\n}"
		$ItemTooltip/meta.text = s
	else:
		$ItemTooltip/meta.hide()


func _process(delta: float) -> void:
	if not ponder.visible:
		return
	
	if Input.is_action_pressed("game_ponder"):
		pondertime = move_toward(pondertime, 1.5, delta)
	else:
		pondertime = move_toward(pondertime, 0, delta)
	
	if pondertime > 0:
		var pstr = "[color=#fbb8ec]"
		var a = int(ceil(remap(pondertime, 0, 1.5, 0, 40)))
		var b = 40 - a
		for i in a:
			pstr += "|"
		pstr += "[/color][color=#666666]"
		for i in b:
			pstr += "|"
		ponder.text = pstr
	else:
		ponder.text = pondertext
