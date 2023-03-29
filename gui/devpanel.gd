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
    if "extra" in dat:
        content.append(HSeparator.new())
        content.append(Label.new())
        content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        addExtract(Engine.get_license_text())
        #TODO fix the rest of this freezing the game.
        #I don't know why it does. I don't know how it does. 
        #My only guess is there's just too much text.
        #addExtract(Engine.get_license_info())
        #addExtract(Engine.get_copyright_info())
        #addExtract(Engine.get_author_info())
        #addExtract(Engine.get_donor_info())
        
        
func addExtract(obj, addRule := true):
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
            #content.append(HSeparator.new())
            content[-1].text = content[-1].text + "\n---\n"
        #content.append(Label.new())
        #content[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        #content[-1].text = obj
        content[-1].text = content[-1].text + "\n" + obj


func _on_button_pressed():
    var op = load("res://gui/backingpanel.tscn").instantiate()
    $"/root".add_child(op)
    var h := 0
    var j := (" / " + str(content.size()))
    for i in content:
        h += 1
        print("adding " + str(h) + j)
        op.addItem(i.duplicate())
