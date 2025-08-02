extends Node2D
class_name EnemyTwo

@onready var sprite: AnimatedSprite2D = $sprite
@onready var hurtbox: Area2D = $hurtbox
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var fire_detect_area: Area2D = $fire_detect_area
@onready var chase_timer: Timer = $chase_timer
@onready var screen_timer: Timer = $screen_timer

@export var speed: float = 80.0
@export var screen_time: float = 5.0
@export var chase_time: float = 0.85

var direction: Vector2
var velocity: Vector2

func _ready() -> void:
	SignalsBus.flame_died_event.connect(self._on_flame_died)
	screen_timer.timeout.connect(self._on_screen_timer_timeout)
	screen_timer.wait_time = screen_time
	screen_timer.one_shot = true
	screen_timer.start()

	chase_timer.timeout.connect(self._on_chase_timer_timeout)
	chase_timer.wait_time = chase_time
	chase_timer.one_shot = false
	chase_timer.start()

	screen_notifier.screen_exited.connect(self._on_screen_exited)

	fire_detect_area.area_entered.connect(self._on_fire_detected)

	hurtbox.area_entered.connect(self._on_hit)

	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	

	sprite.play("spawn")
	await sprite.animation_finished
	await get_tree().create_timer(0.3).timeout

	_get_player_position()
	
	hurtbox.set_deferred("monitorable", true)
	hurtbox.set_deferred("monitoring", true)
	
	sprite.play("run")
	

func _on_chase_timer_timeout() -> void:
	_get_player_position()

func _on_screen_timer_timeout() -> void:
	chase_timer.stop()


func _get_player_position() -> void:
	var player: Player = SignalsBus.player

	if player != null:
		direction = self.global_position.direction_to(player.global_position)
	else:
		var rand_pos: Vector2 = Vector2(randf_range(0, 640), randf_range(0, 480))
		direction = self.global_position.direction_to(rand_pos)

	velocity = speed * direction


func _on_hit(_area: Area2D) -> void:
	chase_timer.stop()
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	sprite.play("death")
	await sprite.animation_finished
	SignalsBus.enemy_died_event.emit(self.global_position)
	call_deferred("queue_free")

func _on_screen_exited() -> void:
	await get_tree().create_timer(2.0).timeout
	call_deferred("queue_free")

func _on_fire_detected(_area: Area2D) -> void:
	velocity = - velocity

func _physics_process(delta: float) -> void:
	global_position += velocity * delta


func _on_flame_died() -> void:
	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	sprite.play("death")
	await sprite.animation_finished
	call_deferred("queue_free")
