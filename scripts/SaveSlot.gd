extends Button
class_name SaveSlot


@onready var namel := $name
@onready var subl := $sub
@onready var timel := $time
@onready var play := $play
@onready var edit := $edit
@onready var backup := $backup


func _ready():
    play.tooltip_text = Translator.translate(&"gui.worlds.play")
    edit.tooltip_text = Translator.translate(&"gui.worlds.edit")
    backup.tooltip_text = Translator.translate(&"gui.worlds.backup")
