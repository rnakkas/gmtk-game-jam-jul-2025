extends Node2D
class_name Flame

@onready var hp_drain_timer: Timer = $hp_drain_timer
@onready var flame_area: Area2D = $flame_area
@onready var flame: AnimatedSprite2D = $flame

@export var hp: int = 75
@export var hp_drain_time: float = 1.2
@export var hp_drain_respawn: int = 5
@export var hp_recovery_kindling: int = 20

var kindling_count: int

func _ready() -> void:
	SignalsBus.flame_hp_updated_event.emit(hp)

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
	hp = clamp(hp - hp_drain_respawn, 0, 100)

func _get_latest_kindling_count(count: int) -> void:
	kindling_count = count

func _on_player_delivered_kindling(area: Area2D) -> void:
	if area.collision_layer == 128:
		if kindling_count == 0:
			return
		hp = clamp(hp + kindling_count * hp_recovery_kindling, 0, 100)
		
		SignalsBus.flame_feed_event.emit()
		flame.play("feed")
		await get_tree().create_timer(1.5).timeout
		flame.play("idle")
		
		SignalsBus.kindling_count_updated_event.emit(0)
		SignalsBus.flame_hp_updated_event.emit(hp)
