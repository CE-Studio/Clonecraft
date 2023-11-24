extends Panel
class_name BackingPanel

## A generic GUI container.
##
## A generic GUI container useful for menus.[br]
## In-game GUI elements should be created by using [UiManager] if possible.

## A string to display on the panel's close button. Accepts a translation key.[br]
## Should only be set using [method setExit].[br]
## See [Translator].
var exitName = "gui.gameplay.back"
## A list of functions to call when the panel closes, and the objects to call them on.[br]
## A workaround for static callables not currently being possible.[br]
## Should only be set using [method setExit] and [method addExit].
var closeCallbacks:Array[Array] = []
## If the panel shoudl report to the [SettingManager] that it has been closed.[br]
## You probably don't need to touch this.[br]
## Should only be set using [method setExit].
var counted := true

# TODO add a way to add more buttons to the bottom of the panel


func _ready() -> void:
    $HBoxContainer/Button.text = Translator.translate(exitName)


## Configures how the panel will behave when closed.[br]
## [param ename] sets the text on the exit button.[br]
## [param obj] and [param fun] are a workaround for static callables. Pass in an object, 
## and the name of the function to call on it.
func setExit(ename:String, obj:Object = null, fun:StringName = &"", count = true) -> void:
    exitName = ename
    if obj != null:
        closeCallbacks.append([obj, fun])
    counted = count
    

## Adds a callback to be called when the panel closes.[br]
## [param obj] and [param fun] are a workaround for static callables. Pass in an object, 
## and the name of the function to call on it.
func addExit(obj:Object, fun:StringName) -> void:
    closeCallbacks.append([obj, fun])


## Add a [Control] to be displayed inside the panel.
func addItem(item:Control) -> void:
    $Panel/ScrollContainer/Container.add_child(item)


## Close and free the panel.
func close() -> void:
    for i in closeCallbacks:
        i[0].call(i[1])
    if counted:
        SettingManager._layers -= 1
    queue_free()


func _on_button_pressed() -> void:
    close()
