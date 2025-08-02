extends Area2D
class_name BossFireball

@onready var sprite: AnimatedSprite2D = $sprite
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier

@export var speed: float = 120.0 # Change per enenmy

var direction: Vector2 = Vector2.LEFT # Default direction
var angle_deg: float = 180.0 # Default angle, points to the left


func _ready() -> void:
	_connect_to_own_signals()
	direction = - direction.rotated(deg_to_rad(angle_deg)) # Since its facing the left
	self.rotate(deg_to_rad(angle_deg))


func _connect_to_own_signals() -> void:
	area_entered.connect(self._on_area_entered)
	screen_notifier.screen_exited.connect(self._on_screen_notifier_screen_exited)
	


func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


func _on_screen_notifier_screen_exited() -> void:
	await get_tree().create_timer(2.0).timeout
	call_deferred("queue_free")


func _on_area_entered(_area: Area2D) -> void:
	sprite.play("hit")
	await sprite.animation_finished
	call_deferred("queue_free")
