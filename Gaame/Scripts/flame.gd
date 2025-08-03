extends Node2D
class_name Flame

@onready var hp_drain_timer: Timer = $hp_drain_timer
@onready var flame_area: Area2D = $flame_area
@onready var flame: AnimatedSprite2D = $flame
@onready var hurtbox: Area2D = $hurtbox
@onready var altar_area: Area2D = $altar_area
@onready var altar_sprite: AnimatedSprite2D = %altar_sprite
@onready var audio_powerup: AudioStreamPlayer = $audio_powerup
@onready var audio_powerdown: AudioStreamPlayer = $audio_powerdown

@export var hp: int = 100

func _ready() -> void:
	SignalsBus.flame = self

	SignalsBus.flame_hp_updated_event.emit(hp)

	SignalsBus.flame_inferno_ended_event.connect(self._on_flame_inferno_ended)

	altar_area.area_entered.connect(self._on_player_delivered_kindling)
	

func _on_player_delivered_kindling(area: Area2D) -> void:
	if area.collision_layer == 128:
		var player: Player = SignalsBus.player
		if !player.has_kindling:
			return
		player.has_kindling = false
		SignalsBus.player_delivered_kindling_event.emit(0)
		audio_powerup.play()
		flame.play("pre-inferno")
		await flame.animation_finished
		flame.play("inferno")
		SignalsBus.flame_inferno_event.emit()

func _on_flame_inferno_ended(boss_killed: bool, _boss_rank: int) -> void:
	audio_powerdown.play()
	if boss_killed:
		hp = clamp(hp - 25, 0, 100)
		flame.play("post_inferno")
		await flame.animation_finished
		flame.play("idle")

		if hp <= 75 and hp > 50:
			self.scale = Vector2(0.75, 0.75)
		elif hp <= 50 and hp > 25:
			self.scale = Vector2(0.5, 0.5)
		elif hp <= 25:
			self.scale = Vector2(0.25, 0.25)

		if hp <= 0:
			flame.play("die_out")
			await flame.animation_finished
			call_deferred("queue_free")

	else:
		flame.play("post_inferno")
		await flame.animation_finished
		flame.play("idle")
