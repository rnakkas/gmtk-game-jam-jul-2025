extends Control
class_name DialogUi

@onready var dialog_1: Label = %dialog_1
@onready var dialog_2: Label = %dialog_2

@export var fade_in_time: float = 0.3
@export var hold_time: float = 1.0
@export var fade_out_time: float = 0.3
@export var initial_delay: float = 0.0


func _ready() -> void:
	dialog_1.modulate = Color.TRANSPARENT
	dialog_2.modulate = Color.TRANSPARENT
	SignalsBus.flame_died_event.connect(self._on_flame_died)

func _on_flame_died() -> void:
	await get_tree().create_timer(2.5).timeout
	self.visible = true
	play_fade()

# Plays fade-in → hold → fade-out sequence.
func play_fade() -> void:
	SignalsBus.movement_lock_event.emit(true)
	# create new tween chain
	var tween = get_tree().create_tween()

	tween.tween_property(dialog_1, "modulate", Color("#ffffff"), 1.2)
	tween.tween_interval(1.0)
	tween.tween_property(dialog_1, "modulate", Color.TRANSPARENT, 1.5)
	tween.tween_interval(1.0)
	tween.tween_property(dialog_2, "modulate", Color("#ffffff"), 1.5)
	tween.tween_interval(1.5)
	tween.tween_property(dialog_2, "modulate", Color.TRANSPARENT, 1.2)

	await tween.finished

	SignalsBus.game_end_dialog_finished.emit()
	SignalsBus.movement_lock_event.emit(false)
