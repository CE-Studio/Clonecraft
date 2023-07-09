extends Control


@export var dictKey:StringName = &"gui.error.invalid_translation_key"


func _ready():
    self.text = Translator.translate(dictKey)
