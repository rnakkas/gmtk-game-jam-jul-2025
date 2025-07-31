extends Node2D
class_name Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_to_signals()


func _connect_to_signals() -> void:
	SignalsBus.player_shooting_event.connect(self._on_player_shooting_event)

func _on_player_shooting_event(fireball: PlayerFireball) -> void:
	add_child(fireball)
