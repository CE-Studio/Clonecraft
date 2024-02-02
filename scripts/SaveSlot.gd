extends Button
class_name SaveSlot


@onready var namel := $name
@onready var subl := $sub
@onready var timel := $time
@onready var play := $play
@onready var edit := $edit
@onready var backup := $backup
@onready var warn := $warning
@onready var error := $error
@onready var sicon := $icon
var data:Dictionary
var fpath:String

const IMPORTANTKEYS := [
	"streamtype",
	"mods",
	"generator",
	"seed"
]


func _ready():
	play.tooltip_text = Translator.translate(&"gui.worlds.play")
	edit.tooltip_text = Translator.translate(&"gui.worlds.edit")
	backup.tooltip_text = Translator.translate(&"gui.worlds.backup")
	
	
func populate(datain:Dictionary, filepath:String):
	fpath = filepath
	data = datain
	var keys:Array = data.keys()
	if "name" not in keys:
		data["name"] = "Unnamed World"
	if "subtitle" not in keys:
		data["subtitle"] = ""
	if "savetime" not in keys:
		data["savetime"] = "--/--/---- --:--:-- --"
	if "gameversion" not in keys:
		data["gameversion"] = "-.-.-"
	namel.text = data["name"]
	subl.text = data["subtitle"]
	timel.text = data["savetime"]
	
	for i in ["svg", "bmp", "png", "tga", "ktx", "jpg", "webp"]:
		if FileAccess.file_exists(filepath + "/icon." + i):
			var im := Image.load_from_file(filepath + "/icon."+ i)
			var t2d = ImageTexture.new()
			t2d.set_image(im)
			sicon.texture = t2d
			break
	
	for i in IMPORTANTKEYS:
		if i not in keys:
			error.show()
			error.tooltip_text = Translator.translate(&"gui.worlds.corrupted0") + ' "' + i + '"'
			disabled = true
			play.disabled = true
			edit.disabled = true
			backup.disabled = true
			sicon.modulate = Color.hex(0xA9A9A9FF)
			namel.modulate = Color.hex(0xA9A9A9FF)
			subl.modulate = Color.hex(0xA9A9A9FF)
			timel.modulate = Color.hex(0xA9A9A9FF)
			return
		if data["gameversion"] != SettingManager.VERSION:
			warn.show()
			warn.tooltip_text = Translator.translate(&"gui.worlds.versiondiff")
	


func _on_play_pressed():
	BlockManager.modsToLoad = data["mods"]
