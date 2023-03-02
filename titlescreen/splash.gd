extends Label3D

var timer := 0.0
var rng := RandomNumberGenerator.new()
var ch

# TODO: make this load from a file
var splashes:Array[String]


func _ready():
    var j := JSON.new()
    var f := File.new()
    f.open("res://titlescreen/splashes.json", File.READ)
    var stat := j.parse(f.get_as_text())
    f.close()
    if stat == OK:
        splashes = j.get_data()
    else:
        splashes = ["Splash error!"]
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
