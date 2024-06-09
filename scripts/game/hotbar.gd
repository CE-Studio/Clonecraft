class_name Hotbar
extends Control


static var instance:Hotbar
@onready var player:Player = $"../../../player"


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
var slotmodels:Array[MeshInstance3D] = []
var slotlbls:Array[Label] = []


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


# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	call_deferred("_setup")


func _setup():
	player.inventory.contentChanged.connect(redraw)
	var aaa := BoxMesh.new()
	for i in slots:
		slotmodels.append(MeshInstance3D.new())
		ItemManager.addToItemLayer(slotmodels[-1])
		slotmodels[-1].position = ItemManager.posConvert(i.global_position)
		print(i.global_position)
		slotmodels[-1].mesh = aaa
		slotlbls.append(Label.new())
		$"../../GUIlayer2".add_child(slotlbls[-1])
		slotlbls[-1].text = "0"
	redraw()


func deferRedraw():
	call_deferred("redraw")


func redraw():
	for i in layerLights:
		i.frame = 1
	layerLights[layer].frame = 0
	selector.position = slots[slot].position + Vector2.UP
	for i in range(slots.size()):
		slotlbls[i].global_position = slots[i].global_position + Vector2(-24, 1)
		slotmodels[i].position = ItemManager.posConvert(slots[i].global_position + Vector2(0, 8))
		var j := player.hotbarItems[i + (10 * layer)]
		if is_instance_valid(j):
			slotmodels[i].show()
			slotmodels[i].mesh = j.getMesh()
			slotlbls[i].show()
			slotlbls[i].text = str(j.count)
			slots[i].frame = 1
		else:
			slotlbls[i].hide()
			slotmodels[i].hide()
			slots[i].frame = 0
