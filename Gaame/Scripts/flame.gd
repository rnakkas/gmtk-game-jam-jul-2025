extends Node2D
class_name Flame

@onready var hp_drain_timer: Timer = $hp_drain_timer

@export var hp_drain_time: float = 1.0

var hp: int

func _ready() -> void:
	hp_drain_timer.timeout.connect(self._on_hp_drain_timer_timeout)
	hp_drain_timer.wait_time = hp_drain_time
	hp_drain_timer.one_shot = false
	hp_drain_timer.start()

	SignalsBus.player_respawn_event.connect(self._on_player_respawn_event)

func _on_hp_drain_timer_timeout() -> void:
	hp = clamp(hp - 1, 0, 100)
	SignalsBus.flame_hp_updated_event.emit(hp)

func _on_player_respawn_event() -> void:
	hp = clamp(hp - 5, 0, 100)