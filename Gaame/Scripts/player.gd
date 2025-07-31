extends CharacterBody2D
class_name Player

## Velocity
@export var _max_speed: float = 300.0
@export var acceleration: float = 900.0
@export var deceleration: float = 1000.0

## Shooting handler
# @onready var shooting_handler: ShootingHandler = $shooting_handler

## Sprites
@onready var sprite: AnimatedSprite2D = $sprite

## Hurtbox
# @onready var hurtbox: Area2D = $hurtbox

## Timers
# @export var invincibility_time: float = 2.0
# @onready var invincibility_timer: Timer = $invincibility_timer

var viewport_size: Vector2
var is_dead: bool
var can_be_invincible: bool


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	# invincibility_timer.wait_time = invincibility_time


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
	_handle_invincibility()
	_handle_screen_wrap()
	_flip_sprite()
	
func _handle_invincibility() -> void:
	if can_be_invincible:
		can_be_invincible = false
		# invincibility_timer.start()
		
		# hurtbox.set_deferred("monitoring", false)
		# hurtbox.set_deferred("monitorable", false)

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

################################################
# NOTE: Game pause handler
################################################
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SignalsBus.player_pressed_pause_game_event.emit()


# ################################################
# # NOTE: Hurtbox signal
# # Handle getting hit by enemies or projectiles
# ################################################
# func _on_hurtbox_area_entered(_area: Area2D) -> void:
# 	# To prevent moving, shooting or bombing when dead
# 	is_dead = true
# 	shooting_handler.is_dead = true
# 	bomb_handler.is_dead = true
	
# 	velocity = Vector2.ZERO
# 	hurtbox.set_deferred("monitoring", false)
# 	hurtbox.set_deferred("monitorable", false)
	
# 	rocket.visible = false # Contains body and thruster sprites
# 	death.play("death")

# 	SignalsBus.spawn_powerup_event.emit(self.global_position)
	
# 	await death.animation_finished
	
# 	## wait 0.5 seconds before sending signal to player spawner
# 	await get_tree().create_timer(0.5).timeout
	
# 	SignalsBus.player_death_event.emit()
	
# 	queue_free()
	

# ################################################
# # NOTE: Stop invincibility signal
# ################################################
# func _on_invincibility_timer_timeout() -> void:
# 	# Re-enable hurtbox
# 	hurtbox.set_deferred("monitoring", true)
# 	hurtbox.set_deferred("monitorable", true)
	
# 	# Return to default animations
# 	rocket.visible = true # Contains body and thruster sprites
# 	invincible.play("none")


# ################################################
# #NOTE: Handle shooting signals, used for animations
# ################################################
# func _on_shooting_handler_now_shooting(powerup: GameManager.powerups, level: int) -> void:
# 	if is_dead:
# 		return
# 	body.play("shoot")

# 	match powerup:
# 		GameManager.powerups.None:
# 			base_muzzle_flash.play("shoot")
# 		GameManager.powerups.Overdrive:
# 			od_muzzle_flash.play("shoot")
# 		GameManager.powerups.Chorus:
# 			ch_muzzle_flash.play("shoot")
# 			if level == 4:
# 				ch_muzzle_flash_1.play("shoot")
# 				ch_muzzle_flash_2.play("shoot")


# func _on_shooting_handler_stopped_shooting() -> void:
# 	base_muzzle_flash.play("none")
# 	od_muzzle_flash.play("none")
# 	ch_muzzle_flash.play("none")
# 	ch_muzzle_flash_1.play("none")
# 	ch_muzzle_flash_2.play("none")
# 	body.play("idle")
# 	body.frame = rocket.frame
