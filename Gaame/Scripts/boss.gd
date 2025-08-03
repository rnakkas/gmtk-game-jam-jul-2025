extends Node2D
class_name EnemyBoss

@onready var sprite: AnimatedSprite2D = $sprite
@onready var hurtbox: Area2D = $hurtbox
@onready var chase_timer: Timer = $chase_timer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var shoot_timer: Timer = $shoot_timer
@onready var shoot_timer_2: Timer = $shoot_timer_2
@onready var boss_shooting: BossShooting = $boss_shooting
@onready var boss_shooting_2: BossShooting = $boss_shooting2

@export var speed: float =  70.0
@export var max_hp: int = 1
@export var rank: int = 1

var hp: int
var direction: Vector2
var velocity: Vector2
var viewport_size: Vector2
var player: Player
var stay_on_screen: bool
var can_die: bool = true

func _ready() -> void:
	match rank:
		1:
			hp = max_hp
			boss_shooting.shoot_time = 2.0
			boss_shooting.bullets_per_shot = 3
			boss_shooting.shot_spread_angle = 25.0
		
		2:
			# hp = max_hp + 10
			boss_shooting.shoot_time = 1.75
			boss_shooting.bullets_per_shot = 5
			boss_shooting.shot_spread_angle = 30.0
			boss_shooting_2.bullets_per_shot = 5
			shoot_timer_2.start()
		
		3:
			# hp = max_hp + 20
			boss_shooting.shoot_time = 1.5
			boss_shooting.bullets_per_shot = 7
			boss_shooting.shot_spread_angle = 35.0
			boss_shooting_2.bullets_per_shot = 9
			shoot_timer_2.start()
		
		4:
			# hp = max_hp + 30
			boss_shooting.shoot_time = 1.3
			boss_shooting.bullets_per_shot = 9
			boss_shooting.shot_spread_angle = 40
			boss_shooting_2.bullets_per_shot = 12
			shoot_timer_2.start()

	SignalsBus.player_death_event.connect(self._on_player_death)

	screen_notifier.screen_exited.connect(self._on_screen_exited)

	hurtbox.area_entered.connect(self._on_hit_by_attack)

	player = SignalsBus.player
	viewport_size = get_viewport_rect().size
	direction = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	).normalized()

	sprite.play("spawn")
	await sprite.animation_finished
	sprite.play("idle")


	velocity = direction * speed

	chase_timer.timeout.connect(self._on_chase_timeout)
	chase_timer.one_shot = false
	chase_timer.wait_time = 0.5
	chase_timer.start()

	shoot_timer.start()


func _on_chase_timeout() -> void:
	player = SignalsBus.player
	if player == null:
		return
	direction = self.global_position.direction_to(player.global_position)
	velocity = direction * speed



func _process(_delta: float) -> void:
	if stay_on_screen:
		_clamp_pos_to_screen()

func _clamp_pos_to_screen() -> void:
	position.x = clamp(position.x,100,viewport_size.x - 100)
	position.y = clamp(position.y,100,viewport_size.y - 100)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	

func _on_player_death(_pos: Vector2) -> void:
	chase_timer.stop()
	stay_on_screen = false
	velocity = velocity * 2

func _on_screen_exited() -> void:
	shoot_timer.stop()
	await get_tree().create_timer(1.0).timeout
	SignalsBus.flame_inferno_ended_event.emit(false, rank)
	call_deferred("queue_free")

func _on_hit_by_attack(_area : Area2D) -> void:
	hp = clamp(hp - 1, 0, max_hp)
	self.modulate = Color("#e24b13")
	await get_tree().create_timer(0.05).timeout
	self.modulate = Color("#ffffff")
	
	if hp <= 0:
		if can_die:
			can_die = false
			shoot_timer.stop()
			chase_timer.stop()
			velocity = Vector2.ZERO
			hurtbox.set_deferred("monitorable", false)
			hurtbox.set_deferred("monitoring", false)
			if SignalsBus.flame.hp > 25:
				sprite.play("despawn")
				await sprite.animation_finished
				call_deferred("queue_free")
			else:
				sprite.play("death")
				await sprite.animation_finished
				call_deferred("queue_free")

			SignalsBus.flame_inferno_ended_event.emit(true, rank)
	 
