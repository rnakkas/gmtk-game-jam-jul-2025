extends Area2D
class_name BossFireball

@onready var sprite: AnimatedSprite2D = $sprite
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var audio_shoot: AudioStreamPlayer = $audio_shoot
@onready var audio_hit: AudioStreamPlayer = $audio_hit

@export var speed: float = 120.0 # Change per enenmy

var direction: Vector2 = Vector2.LEFT # Default direction
var angle_deg: float = 180.0 # Default angle, points to the left


func _ready() -> void:
	audio_shoot.play()
	_connect_to_own_signals()
	direction = - direction.rotated(deg_to_rad(angle_deg)) # Since its facing the left
	self.rotate(deg_to_rad(angle_deg))


func _connect_to_own_signals() -> void:
	area_entered.connect(self._on_area_entered)
	screen_notifier.screen_exited.connect(self._on_screen_notifier_screen_exited)
	SignalsBus.flame_died_event.connect(self._on_flame_died)
	


func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


func _on_screen_notifier_screen_exited() -> void:
	await get_tree().create_timer(2.0).timeout
	call_deferred("queue_free")


func _on_area_entered(_area: Area2D) -> void:
	audio_hit.play()
	speed = 0
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	sprite.play("hit")
	await sprite.animation_finished
	call_deferred("queue_free")

func _on_flame_died() -> void:
	speed = 0
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	call_deferred("queue_free")