class_name Hotbar
extends Control


static var instance:Hotbar
@onready var player:Player = $"../../../player"
@onready var timer:Timer = $timer


@onready var layerLights:Array[Sprite2D] = [
	$layer0,
	$layer1,
	$layer2,
	$layer3,
]
@onready var slots:Array[Sprite2D] = [
	$hb1,
	$hb2,
	$hb3,
	$hb4,
	$hb5,
	$hb6,
	$hb7,
	$hb8,
	$hb9,
	$hb10,
]
@onready var selector:Sprite2D = $hbsel


static var slot:int:
	set(value):
		slot = value % 10
		if is_instance_valid(instance):
			instance.redraw()
		
static var layer:int:
	set(value):
		layer = value % 4
		if is_instance_valid(instance):
			instance.redraw()


func _ready():
	instance = self
	call_deferred("_setup")


func _setup():
	player.inventory.contentChanged.connect(redraw)
	redraw()
	timer.start()


func _reallyDeferRedraw():
	redraw()


func deferRedraw():
	call_deferred("redraw")
	timer.start()


func redraw():
	for i in layerLights:
		i.frame = 1
	layerLights[layer].frame = 0
	selector.position = slots[slot].position + Vector2.UP
	for i in range(slots.size()):
		for h in slots[i].get_children():
			h.queue_free()
		var j := player.hotbarItems[i + (10 * layer)]
		if is_instance_valid(j):
			if j.count <= 0:
				player.hotbarItems[i + (10 * layer)] = null
				slots[i].frame = 0
			else:
				var gi:GUIItem = UiManager.createGuiItemstack(j)
				slots[i].add_child(gi)
				gi.position += Vector2(-23, -23)
				slots[i].frame = 1
		else:
			slots[i].frame = 0
