extends Node2D
class_name Game

@onready var flame: Node2D = $flame
@onready var player_sp: Marker2D = $player_sp

var kindling_count: int
var kill_count: int
var flame_hp: int = 75


func _ready() -> void:
	_connect_to_signals()
	flame.hp = flame_hp


func _connect_to_signals() -> void:
	SignalsBus.player_shooting_event.connect(self._on_player_shooting_event)
	SignalsBus.player_death_event.connect(self._on_player_death_evnet)

func _on_player_shooting_event(fireball: PlayerFireball) -> void:
	add_child(fireball)

func _on_player_death_evnet(pos: Vector2) -> void:
	# spawn kindling at player death pos
	var kindling: Kindling = Main.kindling_PS.instantiate()
	kindling.global_position = pos
	add_child(kindling)

	# Respawn player on death
	await get_tree().create_timer(0.3).timeout
	var player: Player = Main.player_PS.instantiate()
	player.global_position = player_sp.global_position
	add_child(player)
	SignalsBus.player_respawn_event.emit()
