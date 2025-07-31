extends Control
class_name MainMenu

@onready var how_to_play_button: Button = %how_to_play_button
@onready var play_button: Button = %play_button
@onready var quit_button: Button = %quit_button
@onready var fullscreen_check: Button = %fullscreen_check

signal how_to_play_button_pressed()
signal play_button_pressed()
signal quit_button_pressed()

var buttons_array: Array[Button] = []

func _ready() -> void:
	buttons_array = [
		how_to_play_button,
		play_button,
		quit_button
	]

	_connect_to_signals()
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		fullscreen_check.button_pressed = false
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or \
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		fullscreen_check.button_pressed = true

func _connect_to_signals() -> void:
	for button: Button in buttons_array:
		button.pressed.connect(self._on_menu_button_pressed)
	visibility_changed.connect(self._on_visibility_changed)
	fullscreen_check.toggled.connect(self._on_fullscreen_check_toggled)

func _on_menu_button_pressed() -> void:
	var current_button: Button
	for button: Button in buttons_array:
		if button.has_focus():
			current_button = button
			break
	
	match current_button:
		how_to_play_button:
			how_to_play_button_pressed.emit()
		play_button:
			play_button_pressed.emit()
		quit_button:
			quit_button_pressed.emit()

func _on_visibility_changed() -> void:
	if !visible:
		how_to_play_button.disabled = true
		play_button.disabled = true
		quit_button.disabled = true
	else:
		how_to_play_button.disabled = false
		play_button.disabled = false
		quit_button.disabled = false

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)