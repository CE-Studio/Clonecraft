extends GridContainer


func _ready():
    $"Play".connect("pressed", play)
    $"Options".connect("pressed", openOptions)
    $"Quit".connect("pressed", get_tree().quit)


func play():
    get_tree().change_scene_to_file("res://node_3d.tscn")


func openOptions():
    var op = load("res://settings/settings.tscn").instantiate()
    $"/root".add_child(op)
