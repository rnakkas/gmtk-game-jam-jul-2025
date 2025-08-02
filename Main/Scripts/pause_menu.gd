extends Control
class_name PauseMenu

@onready var resume_button: Button = %resume_button
@onready var main_menu_button: Button = %main_menu_button
@onready var quit_button: Button = %quit_button_pause_menu

signal return_to_main_menu_from_pause()

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(self._on_resume_pressed)
	main_menu_button.pressed.connect(self._on_main_menu_presed)
	quit_button.pressed.connect(self._on_quit_pressed)
	SignalsBus.player_pressed_pause_game_event.connect(self._on_paused_game)

func _on_paused_game() -> void:
	get_tree().paused = true
	self.visible = true

func _on_resume_pressed() -> void:
	self.visible = false
	get_tree().paused = false

func _on_main_menu_presed() -> void:
	return_to_main_menu_from_pause.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()
	
