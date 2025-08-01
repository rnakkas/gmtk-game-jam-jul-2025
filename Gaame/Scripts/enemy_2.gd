extends Node2D
class_name EnemyTwo

@onready var sprite: AnimatedSprite2D = $sprite
@onready var hurtbox: Area2D = $hurtbox

@export var speed: float = 80.0

var direction: Vector2
var velocity: Vector2

func _ready() -> void:
	hurtbox.area_entered.connect(self._on_hit)

	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	
	sprite.play("spawn")
	await sprite.animation_finished
	await get_tree().create_timer(0.3).timeout
	
	hurtbox.set_deferred("monitorable", true)
	hurtbox.set_deferred("monitoring", true)
	
	sprite.play("run")
	
	var viewport_size: Vector2 = get_viewport_rect().size
	direction = self.global_position.direction_to(Vector2(viewport_size.x / 2, (viewport_size.y / 2) + 30.0))
	velocity = speed * direction

func _on_hit(_area: Area2D) -> void:
	velocity = velocity * 0.15
	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	sprite.play("death")
	await sprite.animation_finished
	SignalsBus.enemy_died_event.emit()
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
