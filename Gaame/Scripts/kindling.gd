extends Area2D
class_name Kindling

@onready var sprite: AnimatedSprite2D = $sprite
@onready var despawn_timer: Timer = $despawn_timer

@export var despawn_time: float = 5.0


func _ready() -> void:
	area_entered.connect(self._on_player_picked_up_kindling)

	despawn_timer.timeout.connect(self._on_despawn_timer_timeout)
	despawn_timer.wait_time = despawn_time
	despawn_timer.one_shot = true
	despawn_timer.start()

func _on_player_picked_up_kindling(_area: Area2D) -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	sprite.stop()

	# Tween when collected
	var tween = get_tree().create_tween()
	var final_position: Vector2 = Vector2(self.position.x, self.position.y - 32.0)

	tween.set_parallel(true)

	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property(self, "position", final_position, 0.4)

	await tween.finished
	SignalsBus.kindling_picked_up_event.emit()
	call_deferred("queue_free")

func _on_despawn_timer_timeout() -> void:
	_despawn()

func _despawn() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	sprite.play("despawn")
	await sprite.animation_finished
	call_deferred("queue_free")