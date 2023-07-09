extends Panel
class_name BackingPanel


var exitName = "gui.gameplay.back"
var closeCallbacks:Array[Callable] = []


func _ready() -> void:
    $HBoxContainer/Button.text = Translator.translate(exitName)


func setExit(ename:String, cb:Callable = Callable()):
    exitName = ename
    if cb.is_valid():
        closeCallbacks.append(cb)


func addItem(item:Control) -> void:
    $Panel/ScrollContainer/Container.add_child(item)


func close() -> void:
    for i in closeCallbacks:
        i.call()
    queue_free()


func _on_button_pressed() -> void:
    close()
