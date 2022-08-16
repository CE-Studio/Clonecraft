extends Label3D

var timer := 0.0
var rng := RandomNumberGenerator.new()
var ch

# TODO: make this load from a file
var splashes := [
	"No megacorps involved!",
	"owo",
	"uwu",
	"<w<;;",
	"Totally (un)original!",
	"I go up and I go down!",
	"He he he, yup!",
	"lolwut",
	"I don't make the rules.\n(Except for when I do)",
	"derg",
	"Also try Minetest!",
	"Meet hot singles in\n{{location.state}} today!",
	"ver good 11/10 best game",
	"ai';gr.h;ldajkosae4-04ww",
	"Weh!",
	"Pipis room!",
	"Get it and I'll\nthrow in a free\nL I G H T S W I T C H E S !",
	"Kersnoozle!",
	"Shoo be doo\nshoo-shoo be doo!",
	"That's right!",
	"Press the <any>\nkey to continue!",
	"Llamas around the walk!",
]


func _ready():
	ch = get_child(0)
	rng.randomize()
	text = splashes[rng.randi_range(0, splashes.size() - 1)]
	ch.text = text


func _input(event):
	if event.is_action_pressed("ui_up"):
		rng.randomize()
		text = splashes[rng.randi_range(0, splashes.size() - 1)]
		ch.text = text


func _process(delta):
	var s = (abs(sin(timer * 4)) / 5) + 1
	var r = deg2rad((sin(timer * 4) * 3) + 16.8)
	scale = Vector3(s, s, s)
	rotation.z = r
	timer += delta
