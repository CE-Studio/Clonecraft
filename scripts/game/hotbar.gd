class_name Hotbar
extends Control


static var instance:Hotbar
@onready var player:Player = $"../../../player"


# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	call_deferred("_setup")


func _setup():
	player.inventory.contentChanged.connect(redraw)


func redraw():
	pass
