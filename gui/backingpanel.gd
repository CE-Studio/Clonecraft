extends Panel
class_name BackingPanel


var exitName = "gui.gameplay.back"
var closeCallbacks:Array[Array] = []


func _ready() -> void:
    $HBoxContainer/Button.text = Translator.translate(exitName)


func setExit(ename:String, obj:Object = null, fun:StringName = &"") -> void:
    exitName = ename
    if obj != null:
        closeCallbacks.append([obj, fun])


func addItem(item:Control) -> void:
    $Panel/ScrollContainer/Container.add_child(item)


func close() -> void:
    for i in closeCallbacks:
        i[0].call(i[1])
    queue_free()


func _on_button_pressed() -> void:
    close()
