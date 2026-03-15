extends Button
class_name SaveSlot


@onready var name_label:Label = $name
@onready var sub_label:Label = $sub
@onready var time_label:Label = $time
@onready var play:Button = $play
@onready var edit:Button = $edit
@onready var backup:Button = $backup
@onready var warn:TextureRect = $warning
@onready var error:TextureRect = $error
@onready var save_icon:TextureRect = $icon
var gens:Dictionary = {}
var data:Dictionary
var file_path:String


const IMPORTANT_KEYS := [
	"streamtype",
	"mods",
	"generator",
	"seed"
]


func show_error(e:String) -> void:
	error.show()
	error.tooltip_text = Translator.translate(e)
	disabled = true
	play.disabled = true
	edit.disabled = true
	backup.disabled = true
	save_icon.modulate = Color.hex(0xA9A9A9FF)
	name_label.modulate = Color.hex(0xA9A9A9FF)
	sub_label.modulate = Color.hex(0xA9A9A9FF)
	time_label.modulate = Color.hex(0xA9A9A9FF)


func _ready():
	play.tooltip_text = Translator.translate(&"gui.worlds.play")
	edit.tooltip_text = Translator.translate(&"gui.worlds.edit")
	backup.tooltip_text = Translator.translate(&"gui.worlds.backup")


func populate(data_in:Dictionary, filepath:String):
	file_path = filepath
	data = data_in
	var keys:Array = data.keys()
	if "name" not in keys:
		data["name"] = "Unnamed World"
	if "subtitle" not in keys:
		data["subtitle"] = ""
	if "savetime" not in keys:
		data["savetime"] = "--/--/---- --:--:-- --"
	if "gameversion" not in keys:
		data["gameversion"] = "-.-.-"
	name_label.text = data["name"]
	sub_label.text = data["subtitle"]
	time_label.text = data["savetime"]
	
	for i in ["svg", "bmp", "png", "tga", "ktx", "jpg", "webp"]:
		if FileAccess.file_exists(filepath + "/icon." + i):
			var im := Image.load_from_file(filepath + "/icon."+ i)
			var t2d = ImageTexture.new()
			t2d.set_image(im)
			save_icon.texture = t2d
			break
	
	for i in IMPORTANT_KEYS:
		if i not in keys:
			show_error(Translator.translate(&"gui.worlds.corrupted0") + ' "' + i + '"')
			return

	if data["gameversion"] != SettingManager.VERSION:
		warn.show()
		warn.tooltip_text = Translator.translate(&"gui.worlds.versiondiff")
	
	for i in data["mods"]:
		if not ResourceLoader.exists("res://mods/" + i + "/" + i + ".gd"):
			show_error(Translator.translate(&"gui.worlds.mod_missing") + ' "' + i + '"')
			return
		if ResourceLoader.exists("res://mods/" + i + "/generators.json"):
			var f := FileAccess.open("res://mods/" + i + "/generators.json", FileAccess.READ)
			var g = JSON.parse_string(f.get_as_text())
			f.close()
			if g != null:
				gens.merge(g, true)
	
	if not (data["generator"] in gens.keys()):
		show_error(&"gui.worlds.generator_missing")
		return
		
	if not ResourceLoader.exists(gens[data["generator"]]["path"]):
		show_error(&"gui.worlds.generator_code_missing")
		return


func _on_play_pressed():
	var g = load(gens[data["generator"]]["path"])
	if g is VoxelGenerator:
		WorldControl.generator = g
	else:
		show_error(&"gui.worlds.generator_not_a_generator")
		return
	BlockManager.mods_to_load = data["mods"]
	WorldControl.world_path = file_path
	WorldControl.stream_type = data["streamtype"]
	WorldControl.seed = data["seed"]
	get_tree().change_scene_to_file("res://node_3d.tscn")
