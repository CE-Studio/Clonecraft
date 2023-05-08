extends Node

var translations := {}

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func translate(inp:StringName) -> String:
    if translations.has(inp):
        return translations[inp]
    else:
        print("missing translation key: " + inp)
        return inp
