extends Node

#TODO swap to godot's builtin settings system
#TODO better version system
const VERSION = "Alpha 0.0.1"
const DEFAULT_SETTINGS := {
    #TODO renderDistance
    "renderDistance": 128,
    #TODO shadowDistance
    "shadowDistance": 128,
    #TODO fov
    "fov": 75
}

var settings := {}

#TODO load settings from disk
func _ready():
    settings.merge(DEFAULT_SETTINGS, false)

#TODO save settings to disk
