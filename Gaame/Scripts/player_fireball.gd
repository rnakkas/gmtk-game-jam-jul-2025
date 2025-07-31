extends Area2D
class_name PlayerFireball

@onready var lifetime_timer: Timer = $lifetime_timer
@onready var friendly_fire_timer: Timer = $friendly_fire_timer
@onready var sprite: AnimatedSprite2D = $sprite

@export var damage: int = 1
@export var speed: float = 320.0
@export var lifetime: float = 3.0
@export var friendly_fire_time: float = 0.5

var direction: float
var velocity: Vector2
var viewport_size: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = get_viewport_rect().size

	velocity.x = direction * speed

	lifetime_timer.timeout.connect(self._on_lifetime_timer_timeout)
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = lifetime
	lifetime_timer.start()

	friendly_fire_timer.timeout.connect(self._on_friendly_fire_timer_timeout)
	friendly_fire_timer.one_shot = true
	friendly_fire_timer.wait_time = friendly_fire_time
	friendly_fire_timer.start()

	area_entered.connect(self._on_area_hit)

func _on_lifetime_timer_timeout() -> void:
	sprite.play("hit")
	await sprite.animation_finished
	call_deferred("queue_free")

func _on_area_hit(_area: Area2D) -> void:
	velocity = Vector2.ZERO
	sprite.play("hit")
	await sprite.animation_finished
	call_deferred("queue_free")

func _on_friendly_fire_timer_timeout() -> void:
	## Tween the label when powerup collected
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(sprite, "self_modulate", Color("#e24b13"), 0.7)

	
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 1.0)
	
	set_deferred("collision_mask", 75)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _process(_delta: float) -> void:
	if self.global_position.x > viewport_size.x:
		self.global_position.x = 10.0
	elif self.global_position.x < 0.0:
		self.global_position.x = viewport_size.x - 10.0