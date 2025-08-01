extends Node2D
class_name Flame

@onready var hp_drain_timer: Timer = $hp_drain_timer
@onready var flame_area: Area2D = $flame_area
@onready var flame: AnimatedSprite2D = $flame

@export var hp_drain_time: float = 1.0

var hp: int
var kindling_count: int

func _ready() -> void:
	hp_drain_timer.timeout.connect(self._on_hp_drain_timer_timeout)
	hp_drain_timer.wait_time = hp_drain_time
	hp_drain_timer.one_shot = false
	hp_drain_timer.start()

	flame_area.area_entered.connect(self._on_player_delivered_kindling)

	SignalsBus.player_respawn_event.connect(self._on_player_respawn_event)
	SignalsBus.kindling_count_updated_event.connect(self._get_latest_kindling_count)

func _on_hp_drain_timer_timeout() -> void:
	hp = clamp(hp - 1, 0, 100)
	SignalsBus.flame_hp_updated_event.emit(hp)

func _on_player_respawn_event() -> void:
	hp = clamp(hp - 5, 0, 100)

func _get_latest_kindling_count(count: int) -> void:
	kindling_count = count

func _on_player_delivered_kindling(area: Area2D) -> void:
	if area.collision_layer == 128:
		if kindling_count == 0:
			return
		hp += kindling_count * 15
		SignalsBus.kindling_count_updated_event.emit(kindling_count)
		SignalsBus.flame_hp_updated_event.emit(hp)
		
		flame.play("feed")
		await flame.animation_finished
		flame.play("idle")
