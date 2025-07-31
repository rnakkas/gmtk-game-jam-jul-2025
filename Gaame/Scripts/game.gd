extends Node2D
class_name Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_to_signals()


func _connect_to_signals() -> void:
	SignalsBus.player_shooting_event.connect(self._on_player_shooting_event)
	SignalsBus.player_death_event.connect(self._on_player_death_evnet)

func _on_player_shooting_event(fireball: PlayerFireball) -> void:
	add_child(fireball)

func _on_player_death_evnet(pos: Vector2) -> void:
	await get_tree().create_timer(0.3).timeout
	var player: Player = Main.player_PS.instantiate()
	player.global_position = pos
	add_child(player)
