extends Object
class_name Translator


static var fallback := &"res://lang/en_us.json"


static var translations := {}


static func slog(message:String) -> String:
	var out:String = "[" + Time.get_datetime_string_from_system() + "] [Translator] " + message
	print(out)
	return out


static func _recurExtract(base:String, cont:Dictionary) -> void:
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


static func _sinit() -> void:
	if not loadFromJson(fallback):
		slog("Error loading language!")


static func translate(inp:StringName) -> String:
	if translations.has(inp):
		return translations[inp]
	else:
		slog("missing translation key: " + inp)
		return inp
