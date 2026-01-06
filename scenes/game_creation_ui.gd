extends Control

signal create_grid(width : int, height : int)

@onready var width_control = $MarginContainer/VBoxContainer/Width/SpinBox
@onready var height_control = $MarginContainer/VBoxContainer/Height/SpinBox

func _on_button_pressed() -> void:
    
    var width = width_control.value
    var height = height_control.value
    
    create_grid.emit(width, height)
