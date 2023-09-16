extends Object
class_name Translator


static var fallback := &"res://lang/en_us.json"


static var translations := {}


static func _recurExtract(base:String, cont:Dictionary):
    for i in cont.keys():
        if cont[i] is String:
            translations[base + i] = cont[i]
        elif cont[i] is Dictionary:
            _recurExtract(base + i + ".", cont[i])


static func loadFromJson(path:String) -> bool:
    var j := JSON.new()
    var f := FileAccess.open(path, FileAccess.READ)
    var stat := j.parse(f.get_as_text())
    f.close()
    if stat != OK:
        return false
    if not (j.get_data() is Dictionary):
        return false
    _recurExtract("", j.get_data())
    return true


static func _sinit():
    if not loadFromJson(fallback):
        print("Error loading language!")


static func translate(inp:StringName) -> String:
    if translations.has(inp):
        return translations[inp]
    else:
        print("missing translation key: " + inp)
        return inp
