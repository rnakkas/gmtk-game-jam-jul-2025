extends Node2D
class_name Game

@onready var flame: Node2D = $flame
@onready var player_sp: Marker2D = $player_sp
@onready var enemies_container: Node2D = $enemies_container
@onready var spawn_timer: Timer = $enemy_spawn_timer

@export var enemies_list: Array[PackedScene]
@export var max_spawn_time: float = 2.8
@export var min_spawn_time: float = 1.6

var kindling_count: int
var kill_count: int

var valid_spawn_pos: Vector2


func _ready() -> void:
	SignalsBus.kindling_count_updated_event.emit(kindling_count)
	SignalsBus.kill_count_updated_event.emit(kill_count)

	_connect_to_signals()
	_spawn_timer_stuff()


func _connect_to_signals() -> void:
	SignalsBus.player_shooting_event.connect(self._on_player_shooting_event)
	SignalsBus.player_death_event.connect(self._on_player_death_evnet)
	SignalsBus.kindling_picked_up_event.connect(self._on_kindling_picked_up_event)
	SignalsBus.enemy_shooting_event.connect(self._on_enemy_shooting_event)
	SignalsBus.enemy_died_event.connect(self._on_enemy_died_event)


func _spawn_timer_stuff() -> void:
	spawn_timer.timeout.connect(self._on_spawn_timer_timeout)
	spawn_timer.one_shot = false
	spawn_timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	spawn_timer.start()


#### Enemy spawning logic
func _on_spawn_timer_timeout() -> void:
	var enemy: Node2D = enemies_list.pick_random().instantiate()
	enemy.global_position = _get_valid_spoint_point()
	enemies_container.add_child(enemy)

func _get_valid_spoint_point() -> Vector2:
	# var valid_x_pos_1: float = randf_range(40.0, 230.0)
	# var valid_x_pos_2: float = randf_range(440.0, 600.0)
	var valid_x_pos: float = randf_range(30.0, 610.0)
	var valid_y_pos_1: float = randf_range(30.0, 140.0)
	var valid_y_pos_2: float = randf_range(410.0, 450.0)

	# var valid_x_pos_arr: Array[float] = [valid_x_pos_1, valid_x_pos_2]
	var valid_y_pos_arr: Array[float] = [valid_y_pos_1, valid_y_pos_2]

	var spawn_point: Vector2 = Vector2(
		valid_x_pos,
		valid_y_pos_arr.pick_random()
	)
	
	return spawn_point


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

func _on_enemy_shooting_event(fireball: EnemyFireballOne) -> void:
	add_child(fireball)

func _on_enemy_died_event() -> void:
	kill_count += 1
	SignalsBus.kill_count_updated_event.emit(kill_count)