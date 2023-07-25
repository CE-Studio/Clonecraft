extends Button

var credcontent := {}
var dp := preload("res://gui/devpanel.tscn")
var op:Node

func _pressed() -> void:
    op = load("res://gui/backingpanel.tscn").instantiate()
    $"/root".add_child(op)
    disabled = true

    var dir := DirAccess.open("res://mods")
    dir.include_navigational = false
    var j := JSON.new()
    for i in dir.get_directories():
        if dir.dir_exists( i + "/credits"):
            if FileAccess.file_exists("res://mods/" + i + "/credits/content.json"):
                var f := FileAccess.open("res://mods/" + i + "/credits/content.json", FileAccess.READ)
                if j.parse(f.get_as_text()) == OK:
                    var c = j.get_data()
                    credcontent[c["group"]] = c
    for i in credcontent:
        var h = credcontent[i]
        var k = dp.instantiate()
        op.addItem(k)
        k.populate(h)


func _ready():
    text = Translator.translate(&"gui.generic.support")


func _process(_delta):
    disabled = is_instance_valid(op)
