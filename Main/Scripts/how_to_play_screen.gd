extends Control
class_name HowToPlayScreen

@onready var back_button: Button = %back_to_main_menu_button
@onready var audio_focus: AudioStreamPlayer = $audio_how_to_play_focus
@onready var audio_back: AudioStreamPlayer = $audio_how_to_play_back

signal back_button_pressed()

func _ready() -> void:
	back_button.pressed.connect(self._on_back_button_pressed)
	back_button.mouse_entered.connect(self._on_hovered)

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
	audio_back.play()

func _on_hovered() -> void:
	audio_focus.play()