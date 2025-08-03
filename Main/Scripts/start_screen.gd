extends Control
class_name StartScreen

@onready var press_button_label: Label = %press_button_label
@onready var blink_timer: Timer = $blink_timer
@onready var audio: AudioStreamPlayer = $audio_start_screen

signal start_screen_button_pressed()

var blink_time_idle: float = 0.5
var blink_time_pressed: float = 0.1

func _ready() -> void:
	_connect_to_signals()
	blink_timer.wait_time = blink_time_idle
	blink_timer.one_shot = false
	blink_timer.start()


func _connect_to_signals() -> void:
	blink_timer.timeout.connect(self._on_blink_timer_timeout)

func _on_blink_timer_timeout() -> void:
	press_button_label.visible = !press_button_label.visible


func _input(event: InputEvent) -> void:
	if !visible:
		return
	# Check any keyboard key or mouse button pressed
	if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
		audio.play()
		blink_timer.wait_time = blink_time_pressed
		await get_tree().create_timer(0.75).timeout
		blink_timer.stop()
		start_screen_button_pressed.emit()
