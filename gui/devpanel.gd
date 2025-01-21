extends Panel


var dat := {}
var content:Array[Control] = []


func populate(data:Dictionary) -> void:
	dat = data
	$TextureRect.texture = load(dat["logo"])
	$Label.text = dat["name"]
	$Label2.text = dat["note"]
	content.append(TextureRect.new())
	content[-1].expand_mode = TextureRect.EXPAND_KEEP_SIZE
	content[-1].stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	content[-1].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content[-1].texture = load(dat["banner"])
	content.append(HSeparator.new())
	content.append(Label.new())
	content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content[-1].text = dat["name"]
	content.append(HSeparator.new())
	content.append(Label.new())
	content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content[-1].text = dat["desc"]
	content.append(HSeparator.new())
	for i in dat["support_links"]:
		content.append(LinkButton.new())
		content[-1].text = i
		content[-1].uri = i
	if "extra" in dat:
		if dat["extra"] is String:
			content.append(HSeparator.new())
			content.append(Label.new())
			content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			if dat["extra"] == "":
				addExtract(Engine.get_license_text())
				addExtract(Engine.get_license_info())
				addExtract(Engine.get_copyright_info())
				addExtract(Engine.get_author_info())
				addExtract(Engine.get_donor_info())
			else:
				addExtract(dat["extra"])
		elif ((dat["extra"] is Array) or (dat["extra"] is Dictionary)):
			content.append(HSeparator.new())
			content.append(Label.new())
			content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			addExtract(dat["extra"])
		else:
			print("the fucc is this???")


func addExtract(obj, addRule := true) -> void:
	if obj is Dictionary:
		for i in obj:
			if obj[i] is String:
				addExtract(i + ": " + obj[i], addRule)
			else:
				addExtract(i, addRule)
				addExtract(obj[i], false)
	elif obj is Array:
		for i in obj:
			addExtract(i, addRule)
	elif obj is String:
		if addRule:
			content.append(HSeparator.new())
		content.append(Label.new())
		content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content[-1].text = obj


func _on_button_pressed() -> void:
	var op:BackingPanel = load("res://gui/backingpanel.tscn").instantiate()
	$"/root".add_child(op)
	var h := 0
	var j := (" / " + str(content.size()))
	var c := 0
	op.getExitButton().disabled = true
	for i in content:
		h += 1
		c += 1
		op.addItem(i.duplicate())
		if c > 10:
			c = 0
			op.getExitButton().text = "adding " + str(h) + j
			await get_tree().process_frame
	op.getExitButton().disabled = false
	op.getExitButton().text = Translator.translate(op.exitName)
