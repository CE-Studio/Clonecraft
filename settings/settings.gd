extends PanelContainer


func _ready():
    $"GridContainer/Close".connect("pressed", close)


func close():
    queue_free()
