extends Node

var player: Player
var flame: Flame

@warning_ignore("unused_signal")
signal player_pressed_pause_game_event()

@warning_ignore("unused_signal")
signal player_shooting_event(fireball: PlayerFireball)

@warning_ignore("unused_signal")
signal player_hit_event()

@warning_ignore("unused_signal")
signal player_death_event(pos: Vector2)

@warning_ignore("unused_signal")
signal player_respawn_event()

@warning_ignore("unused_signal")
signal kill_count_updated_event(count: int)

@warning_ignore("unused_signal")
signal flame_hp_updated_event(hp: int)

@warning_ignore("unused_signal")
signal kindling_picked_up_event()

@warning_ignore("unused_signal")
signal kindling_count_updated_event(count: int)

@warning_ignore("unused_signal")
signal flame_feed_event()

@warning_ignore("unused_signal")
signal enemy_shooting_event(fireball: EnemyFireballOne)

@warning_ignore("unused_signal")
signal boss_shooting_event(fireball_array: Array[Area2D])

@warning_ignore("unused_signal")
signal enemy_died_event(pos: Vector2)

@warning_ignore("unused_signal")
signal flame_hit_event()

@warning_ignore("unused_signal")
signal flame_died_event()

@warning_ignore("unused_signal")
signal game_over_event()

@warning_ignore("unused_signal")
signal player_delivered_kindling_event(count: int)

@warning_ignore("unused_signal")
signal flame_inferno_event()

@warning_ignore("unused_signal")
signal flame_inferno_ended_event(boss_killed: bool, boss_rank: int)

@warning_ignore("unused_signal")
signal returned_main_menu_from_game()

@warning_ignore("unused_signal")
signal game_end_dialog_finished()

@warning_ignore("unused_signal")
signal movement_lock_event(lock: bool)
