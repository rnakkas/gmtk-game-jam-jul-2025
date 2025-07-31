extends Node2D
class_name Main

@onready var ui_layer: UiLayer = $ui_layer

@export var game_PS: PackedScene = preload("res://Gaame/Scenes/game.tscn")


func _ready() -> void:
	_connect_to_signals()

func _connect_to_signals() -> void:
	ui_layer.play_game_selected.connect(self._on_play_game_selected)

func _on_play_game_selected() -> void:
	var game: Node2D = game_PS.instantiate()
	add_child(game)


func _input(_event: InputEvent) -> void:
	if !OS.is_debug_build():
		return
	if Input.is_key_label_pressed(KEY_Q): # quit game
		get_tree().quit()
	
	if Input.is_key_label_pressed(KEY_R): # reset game
		get_tree().paused = false
		get_tree().reload_current_scene()
