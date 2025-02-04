extends Button


static var ttip := preload("res://gui/ItemTooltip.tscn")


func _make_custom_tooltip(for_text: String) -> Object:
	var t:ItemTooltip = ttip.instantiate()
	t.text = for_text
	t.item = get_parent().item
	return t
