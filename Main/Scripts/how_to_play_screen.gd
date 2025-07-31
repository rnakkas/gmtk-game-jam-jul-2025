extends Control
class_name HowToPlayScreen

@onready var back_button: Button = %back_to_main_menu_button

signal back_button_pressed()

func _ready() -> void:
    back_button.pressed.connect(self._on_back_button_pressed)

func _on_back_button_pressed() -> void:
    back_button_pressed.emit()