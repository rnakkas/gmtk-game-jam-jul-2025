extends Area2D
class_name EnemyFireballOne

@onready var sprite: AnimatedSprite2D = $sprite
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier

@export var speed: float = 120.0

var direction: Vector2
var velocity: Vector2
var angle_deg: float

func _ready() -> void:
	screen_notifier.screen_exited.connect(self._on_screen_exited)
	area_entered.connect(self._on_target_hit)
	direction = direction.rotated(deg_to_rad(angle_deg))
	velocity = speed * direction

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_screen_exited() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.3).timeout
	call_deferred("queue_free")

func _on_target_hit(_area: Area2D) -> void:
	velocity = Vector2.ZERO
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	sprite.play("hit")
	await sprite.animation_finished
	call_deferred("queue_free")