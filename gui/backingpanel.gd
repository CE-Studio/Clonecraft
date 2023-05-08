extends Panel
class_name BackingPanel


func addItem(item:Control) -> void:
    $Panel/ScrollContainer/Container.add_child(item)


func close() -> void:
    queue_free()


func _on_button_pressed() -> void:
    close()
