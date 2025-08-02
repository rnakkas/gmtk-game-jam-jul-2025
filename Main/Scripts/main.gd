extends Node2D
class_name Main

@onready var ui_layer: UiLayer = $ui_layer
@onready var flame_sprite: AnimatedSprite2D = $flame

var game_scene: PackedScene = preload("res://Gaame/Scenes/game.tscn")
static var player_PS: PackedScene = preload("res://Gaame/Scenes/player.tscn")
static var player_fireball_PS: PackedScene = preload("res://Gaame/Scenes/player_fireball.tscn")
static var kindling_PS: PackedScene = preload("res://Gaame/Scenes/kindling.tscn")
static var boss_PS: PackedScene = preload("res://Gaame/Scenes/boss.tscn")

var game: Game

func _ready() -> void:
	_connect_to_signals()

func _connect_to_signals() -> void:
	ui_layer.play_game_selected.connect(self._on_play_game_selected)
	SignalsBus.returned_main_menu_from_game.connect(self._on_returned_to_menu_from_game)

func _on_play_game_selected() -> void:
	game = game_scene.instantiate()
	add_child(game)
	flame_sprite.visible = false


func _input(_event: InputEvent) -> void:
	if !OS.is_debug_build():
		return
	if Input.is_key_label_pressed(KEY_Q): # quit game
		get_tree().quit()
	
	if Input.is_key_label_pressed(KEY_R): # reset game
		get_tree().paused = false
		get_tree().reload_current_scene()

func _on_returned_to_menu_from_game() -> void:
	game.call_deferred("queue_free")
	flame_sprite.visible = true
	
