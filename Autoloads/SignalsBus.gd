extends Node

@warning_ignore("unused_signal")
signal player_pressed_pause_game_event()

@warning_ignore("unused_signal")
signal player_shooting_event(fireball: PlayerFireball)

@warning_ignore("unused_signal")
signal player_death_event(pos: Vector2)

@warning_ignore("unused_signal")
signal player_respawn_event()

@warning_ignore("unused_signal")
signal game_started_event(game_instance: Node2D)

@warning_ignore("unused_signal")
signal flame_hp_updated_event(hp: int)

@warning_ignore("unused_signal")
signal kindling_picked_up_event()

@warning_ignore("unused_signal")
signal kindling_count_updated_event(count: int)