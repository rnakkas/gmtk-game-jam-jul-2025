extends Node2D
class_name EnemyOne

@onready var sprite: AnimatedSprite2D = $sprite
@onready var shoot_timer: Timer = $shoot_timer
@onready var muzzle: Marker2D = $muzzle
@onready var hurtbox: Area2D = $hurtbox

@export var max_shoot_time: float = 2.2
@export var min_shoot_time: float = 1.4
@export var fireball_PS: PackedScene = preload("res://Gaame/Scenes/enemy_fireball_1.tscn")

var shoot_time: float
var direction: Vector2

func _ready() -> void:
	SignalsBus.flame_died_event.connect(self._on_flame_died)
	hurtbox.area_entered.connect(self._on_hit_by_player_or_attack)

	shoot_time = randf_range(min_shoot_time, max_shoot_time)
	shoot_timer.timeout.connect(self._on_shoot_timer_timeout)
	shoot_timer.one_shot = false
	shoot_timer.wait_time = shoot_time

	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	sprite.play("spawn")
	await sprite.animation_finished
	sprite.play("idle")

	hurtbox.set_deferred("monitorable", true)
	hurtbox.set_deferred("monitoring", true)

	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	var player: Player = SignalsBus.player
	if player != null:
		direction = self.global_position.direction_to(player.global_position)
		var fireball: EnemyFireballOne = fireball_PS.instantiate()
		fireball.global_position = muzzle.global_position
		fireball.direction = direction
		SignalsBus.enemy_shooting_event.emit(fireball)

		shoot_time = randf_range(min_shoot_time, max_shoot_time)

		sprite.play("attack")
		await sprite.animation_finished
		sprite.play("idle")
	else:
		return

	
func _on_hit_by_player_or_attack(_area: Area2D) -> void:
	shoot_timer.stop()
	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	sprite.play("death")
	await sprite.animation_finished
	SignalsBus.enemy_died_event.emit(self.global_position)
	call_deferred("queue_free")

func _on_flame_died() -> void:
	shoot_timer.stop()
	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
	sprite.play("death")
	await sprite.animation_finished
	call_deferred("queue_free")