extends Node2D
class_name Game

@onready var flame: Node2D = $flame
@onready var player_sp: Marker2D = $player_sp

var kindling_count: int
var kill_count: int


func _ready() -> void:
	SignalsBus.kindling_count_updated_event.emit(kindling_count)
	SignalsBus.kill_count_updated_event.emit(kill_count)
	
	_connect_to_signals()


func _connect_to_signals() -> void:
	SignalsBus.player_shooting_event.connect(self._on_player_shooting_event)
	SignalsBus.player_death_event.connect(self._on_player_death_evnet)
	SignalsBus.kindling_picked_up_event.connect(self._on_kindling_picked_up_event)

func _on_player_shooting_event(fireball: PlayerFireball) -> void:
	add_child(fireball)

func _on_player_death_evnet(pos: Vector2) -> void:
	# Reset kindling count
	kindling_count = 0
	SignalsBus.kindling_count_updated_event.emit(kindling_count)

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

func _on_kindling_picked_up_event() -> void:
	kindling_count += 1
	SignalsBus.kindling_count_updated_event.emit(kindling_count)