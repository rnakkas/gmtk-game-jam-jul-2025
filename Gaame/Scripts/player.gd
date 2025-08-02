extends CharacterBody2D
class_name Player


## Shooting handler
@onready var shooting_handler: ShootingHandler = $shooting_handler

## Sprites
@onready var sprite: AnimatedSprite2D = $sprite

## Hurtbox
@onready var hurtbox: Area2D = $hurtbox

@onready var invincible_timer: Timer = $invincible_timer
@onready var blink_timer: Timer = $blink_timer

@onready var kindling_area: Area2D = $kindling_area

## Velocity
@export var _max_speed: float = 150.0
@export var acceleration: float = 900.0
@export var deceleration: float = 1000.0

## Timers
@export var invincibility_time: float = 1.7
@export var blink_time: float = 0.1

var viewport_size: Vector2
var is_dead: bool
var can_be_invincible: bool
var has_kindling: bool


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	SignalsBus.player = self
	viewport_size = get_viewport_rect().size

	hurtbox.area_entered.connect(self._on_hit_by_enemy_or_attacks)

	kindling_area.area_entered.connect(self._on_kindling_picked_up)
	
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	invincible_timer.timeout.connect(self._on_invincibility_timer_tiemout)
	invincible_timer.wait_time = invincibility_time
	invincible_timer.one_shot = true
	invincible_timer.start()

	blink_timer.timeout.connect(self._on_blink_timer_timeout)
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = false
	blink_timer.start()


func _on_kindling_picked_up(_area: Area2D) -> void:
	has_kindling = true

func _on_invincibility_timer_tiemout() -> void:
	# Re-enable hurtbox
	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
	# Stop blinking
	blink_timer.stop()
	self.visible = true

func _on_blink_timer_timeout() -> void:
	self.visible = !self.visible


################################################
# NOTE: Physics process
################################################
func _physics_process(delta) -> void:
	if is_dead:
		return
	_handle_movement(delta)
	move_and_slide()

func _handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	# Get input direction
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized() # Normalize for diagonal movement
	
	# Velocity calcs
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * _max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

################################################
# NOTE: Process
################################################
func _process(_delta: float) -> void:
	_handle_screen_wrap()
	_flip_sprite()
	_idle_run_animations()

	if self.global_position.y > viewport_size.y / 2:
		set_deferred("z_index", 3)
	elif self.global_position.y < viewport_size.y / 2:
		set_deferred("z_index", 2)


func _handle_screen_wrap() -> void:
	if self.global_position.x > viewport_size.x:
		global_position.x = 10.0
	elif self.global_position.x < 0:
		global_position.x = viewport_size.x - 10.0
	
	if self.global_position.y > viewport_size.y:
		global_position.y = 10.0
	elif self.global_position.y < 0:
		global_position.y = viewport_size.y - 10.0

func _flip_sprite() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func _idle_run_animations() -> void:
	if velocity != Vector2.ZERO:
		sprite.play("run")
	elif velocity == Vector2.ZERO && !is_dead:
		sprite.play("idle")


################################################
# NOTE: Game pause handler
################################################
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SignalsBus.player_pressed_pause_game_event.emit()


# ################################################
# # Hurtbox signal
# # Handle getting hit by enemies or projectiles
# ################################################
func _on_hit_by_enemy_or_attacks(_area: Area2D) -> void:
	SignalsBus.player_hit_event.emit()
	
	is_dead = true
	shooting_handler.is_dead = true

	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	kindling_area.set_deferred("monitorable", false)
	kindling_area.set_deferred("monitoring", false)

	SignalsBus.player_death_event.emit(self.global_position)

	sprite.play("death")
	await sprite.animation_finished
	
	call_deferred("queue_free")
