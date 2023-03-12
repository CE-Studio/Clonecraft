extends Panel


var dat := {}
var content:Array[Control] = []


func populate(data:Dictionary) -> void:
    dat = data
    $TextureRect.texture = load(dat["author_logo"])
    $Label.text = dat["author_name"]
    $Label2.text = dat["author_note"]
    content.append(TextureRect.new())
    content[-1].expand_mode = TextureRect.EXPAND_KEEP_SIZE
    content[-1].stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
    content[-1].size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content[-1].texture = load(dat["author_banner"])
    content.append(HSeparator.new())
    content.append(Label.new())
    content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content[-1].text = dat["author_name"]
    content.append(HSeparator.new())
    content.append(Label.new())
    content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content[-1].text = dat["author_desc"]
    content.append(HSeparator.new())
    for i in dat["support_links"]:
        content.append(LinkButton.new())
        content[-1].text = i
        content[-1].uri = i


func _on_button_pressed():
    var op = load("res://gui/backingpanel.tscn").instantiate()
    $"/root".add_child(op)
    for i in content:
        op.addItem(i.duplicate())
