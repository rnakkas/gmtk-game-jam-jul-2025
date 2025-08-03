extends Node2D
class_name ShootingHandler

## Base fire rate
@export var base_fire_rate: float = 6

## Muzzles
@onready var muzzle: Marker2D = $muzzle

@onready var audio_shoot: AudioStreamPlayer = %audio_shoot

## Base bullet damage
@export var base_fireball_damage: int = 1

@export var player_sprite: AnimatedSprite2D

## Signals
signal now_shooting()
signal stopped_shooting()

## Misc variables
var is_dead: bool
var on_shooting_cooldown: bool
var shooting_cooldown_time: float
var angle_step: float
var location_base: Vector2
var fire_rate: float
var direction: float
var muzzle_position: Vector2


################################################
# Ready
################################################
func _ready() -> void:
	muzzle_position = muzzle.position
	_update_shooting_properties()


################################################
# Update shooting properties based on powerup
################################################
func _update_shooting_properties() -> void:
	fire_rate = base_fire_rate
	shooting_cooldown_time = 1 / fire_rate


################################################
# NOTE: Process
################################################
func _process(_delta: float) -> void:
	if is_dead:
		return
	_handle_shooting()


################################################
# Main function for handling shooting
################################################
func _handle_shooting() -> void:
	if player_sprite.flip_h:
		direction = -1.0
		muzzle.position.x = - muzzle_position.x
	else:
		direction = 1.0
		muzzle.position.x = muzzle_position.x
	
	
	# Set the muzzle locations every frame
	location_base = muzzle.global_position

	# Only allow shooting if shot limit hasn't been reached
	if Input.is_action_pressed("shoot"):
		if !on_shooting_cooldown:
			on_shooting_cooldown = true

			audio_shoot.play()

			var fireball: PlayerFireball = Main.player_fireball_PS.instantiate()
			fireball.position = location_base
			fireball.damage = base_fireball_damage
			fireball.direction = direction

			# Emit the necessary signals
			now_shooting.emit()
			SignalsBus.player_shooting_event.emit(fireball)
			
			await get_tree().create_timer(shooting_cooldown_time).timeout
			on_shooting_cooldown = false
	else:
		stopped_shooting.emit()
