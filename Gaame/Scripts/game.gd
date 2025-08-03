extends Node2D
class_name Game

@onready var flame: Node2D = $flame
@onready var player_sp: Marker2D = $player_sp
@onready var enemies_container: Node2D = $enemies_container
@onready var spawn_timer: Timer = $enemy_spawn_timer
@onready var spawn_stop_timer: Timer = $spawn_stop_timer
@onready var boss_sp_1: Marker2D = $boss_sp_1
@onready var boss_sp_2: Marker2D = $boss_sp_2

@export var enemies_list: Array[PackedScene]
@export var max_spawn_time: float = 2.8
@export var min_spawn_time: float = 1.6
@export var max_stop_time: float = 60.0
@export var min_stop_time: float = 45.0

var kindling_count: int
var kill_count: int
var inferno: bool
var flame_died: bool

var valid_spawn_pos: Vector2


func _ready() -> void:

	SignalsBus.kindling_count_updated_event.emit(kindling_count)
	SignalsBus.kill_count_updated_event.emit(kill_count)

	_connect_to_signals()
	_spawn_timer_stuff()

	spawn_stop_timer.timeout.connect(self._on_spawn_stop_timeout)
	spawn_stop_timer.one_shot = true
	spawn_stop_timer.wait_time = randf_range(min_stop_time, max_stop_time)
	spawn_stop_timer.start()

func _on_spawn_stop_timeout() -> void:
	spawn_timer.stop()


func _connect_to_signals() -> void:
	SignalsBus.player_shooting_event.connect(self._on_player_shooting_event)
	SignalsBus.player_death_event.connect(self._on_player_death_evnet)
	SignalsBus.kindling_picked_up_event.connect(self._on_kindling_picked_up_event)
	SignalsBus.enemy_shooting_event.connect(self._on_enemy_shooting_event)
	SignalsBus.enemy_died_event.connect(self._on_enemy_died_event)
	SignalsBus.player_delivered_kindling_event.connect(self._on_kindling_delivered)
	SignalsBus.flame_inferno_event.connect(self._on_flame_inferno_event)
	SignalsBus.flame_inferno_ended_event.connect(self._on_flame_inferno_ended)
	SignalsBus.boss_shooting_event.connect(self._on_boss_shooting)
	SignalsBus.game_end_dialog_finished.connect(self._on_game_end_dialog_done)

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
	if !flame_died:
		# Reset kindling count
		kindling_count = 0
		SignalsBus.kindling_count_updated_event.emit(kindling_count)
		
		# Respawn player on death
		await get_tree().create_timer(2.0).timeout

		# spawn kindling at enemy death pos
		if !inferno:
			var kindling: Kindling = Main.kindling_PS.instantiate()
			kindling.global_position = pos
			add_child(kindling)

		var player: Player = Main.player_PS.instantiate()
		player.global_position = player_sp.global_position
		add_child(player)
		SignalsBus.player_respawn_event.emit()
	else:
		SignalsBus.game_over_event.emit()

func _on_kindling_picked_up_event() -> void:
	kindling_count += 1
	SignalsBus.kindling_count_updated_event.emit(kindling_count)

func _on_kindling_delivered(count: int) -> void:
	kindling_count = 0
	kill_count += count
	SignalsBus.kill_count_updated_event.emit(kill_count)

func _on_enemy_shooting_event(fireball: EnemyFireballOne) -> void:
	add_child(fireball)


func _on_flame_inferno_event() -> void:
	inferno = true
	spawn_timer.stop()
	var boss: EnemyBoss = Main.boss_PS.instantiate()
	var sp_arr: Array[Marker2D] = [boss_sp_1, boss_sp_2]
	boss.global_position = sp_arr.pick_random().global_position

	if SignalsBus.flame.hp == 75:
		boss.rank = 2
		spawn_timer.start()
	elif SignalsBus.flame.hp == 50:
		boss.rank = 3
		spawn_timer.start()
	elif SignalsBus.flame.hp <= 25:
		boss.rank = 4 
		spawn_timer.start()
	
	enemies_container.add_child(boss)

func _on_enemy_died_event(_pos: Vector2) -> void:
	pass
	

func _on_game_end_dialog_done() -> void:
	flame_died = true

func _on_flame_inferno_ended(_boss_killed: bool, _boss_rank: int) -> void:
	inferno = false
	if SignalsBus.flame.hp > 0:
		spawn_timer.start()
	else:
		spawn_timer.stop()
		await get_tree().create_timer(1.0).timeout
		SignalsBus.flame_died_event.emit()


func _on_boss_shooting(fireball_array: Array[Area2D]) -> void:
	for fireball: Area2D in fireball_array:
		add_child(fireball)
