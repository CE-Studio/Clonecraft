extends Button
class_name GUIItemBlank


signal clicked(target:GUIItem)
signal slotPressed(slot:int)


var slotID:int = 0


func _on_pressed() -> void:
	clicked.emit(null)
	slotPressed.emit(slotID)
