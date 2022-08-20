extends GridContainer


func _ready():
    $"Play".connect("pressed", play)


func play():
    get_tree().change_scene("res://node_3d.tscn")
