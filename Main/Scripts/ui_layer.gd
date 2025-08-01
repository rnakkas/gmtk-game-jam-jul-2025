extends CanvasLayer
class_name UiLayer

@onready var title: VBoxContainer = %vbox_title
@onready var start_screen: StartScreen = %start_screen
@onready var main_menu: MainMenu = %main_menu
@onready var how_to_play_screen: HowToPlayScreen = %how_to_play_screen
@onready var hud: Hud = %hud
@onready var dialog: DialogUi = %dialog
@onready var pause_menu: PauseMenu = %pause_menu

signal play_game_selected()

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	title.visible = true
	start_screen.visible = true
	main_menu.visible = false
	how_to_play_screen.visible = false
	hud.visible = false
	dialog.visible = false
	pause_menu.visible = false
	_connect_to_signals()

func _connect_to_signals() -> void:
	start_screen.start_screen_button_pressed.connect(self._on_start_screen_button_pressed)
	main_menu.how_to_play_button_pressed.connect(self._on_main_menu_how_to_play_button_pressed)
	main_menu.play_button_pressed.connect(self._on_main_menu_play_button_pressed)
	main_menu.quit_button_pressed.connect(self._on_main_menu_quit_button_pressed)
	how_to_play_screen.back_button_pressed.connect(self._return_to_main_menu_from_how_to_play)
	pause_menu.return_to_main_menu_from_pause.connect(self._return_to_main_menu_from_pause)

func _on_start_screen_button_pressed() -> void:
	start_screen.visible = false
	main_menu.visible = true

func _on_main_menu_how_to_play_button_pressed() -> void:
	main_menu.visible = false
	title.visible = false
	how_to_play_screen.visible = true

func _on_main_menu_play_button_pressed() -> void:
	main_menu.visible = false
	title.visible = false
	hud.visible = true
	play_game_selected.emit()

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")

func _return_to_main_menu_from_how_to_play() -> void:
	how_to_play_screen.visible = false
	title.visible = true
	main_menu.visible = true

func _return_to_main_menu_from_pause() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	hud.visible = false
	main_menu.visible = true
	title.visible = true
	SignalsBus.returned_main_menu_from_game.emit()
