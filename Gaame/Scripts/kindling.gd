extends Area2D
class_name Kindling

@onready var sprite: AnimatedSprite2D = $sprite
@onready var despawn_timer: Timer = $despawn_timer

@export var despawn_time: float = 7.5


func _ready() -> void:
	area_entered.connect(self._on_player_picked_up_kindling)
	SignalsBus.player_death_event.connect(self._on_player_death_event)

	despawn_timer.timeout.connect(self._on_despawn_timer_timeout)
	despawn_timer.wait_time = despawn_time
	despawn_timer.one_shot = true
	despawn_timer.start()

func _on_player_picked_up_kindling(_area: Area2D) -> void:
	print_debug("pickedup")

func _on_player_death_event(_pos: Vector2) -> void:
	_despawn()
	
func _on_despawn_timer_timeout() -> void:
	_despawn()

func _despawn() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	sprite.play("despawn")
	await sprite.animation_finished
	call_deferred("queue_free")