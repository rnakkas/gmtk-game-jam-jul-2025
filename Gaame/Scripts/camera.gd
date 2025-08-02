extends Camera2D
class_name PlayerCamera

# CameraShake.gd
# Attach to Camera2D. External code calls start_shake(...)

@export var default_duration: float = 0.5 # seconds
@export var default_magnitude: float = 12.0 # pixels
@export var default_frequency: float = 25.0 # how fast noise updates (higher = quicker jitter)
@export var enable_rotation: bool = false
@export var max_rotation_degrees: float = 2.0 # degrees for rotational shake

var _remaining: float = 0.0
var _magnitude: float = 0.0
var _frequency: float = 0.0
var _original_offset: Vector2
var _original_rotation: float

# Smooth pseudo-noise state
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _target_offset: Vector2 = Vector2.ZERO
var _current_offset: Vector2 = Vector2.ZERO
var _target_rotation: float = 0.0
var _current_rotation: float = 0.0
var _time_since_update: float = 0.0
var _update_interval: float = 0.04 # will be adjusted based on frequency

func _ready() -> void:
	_original_offset = offset
	_original_rotation = rotation_degrees
	_rng.randomize()
	_reset_internal()

	SignalsBus.player_hit_event.connect(self._on_player_hit_event)
	SignalsBus.flame_feed_event.connect(self._on_flame_feed_event)
	SignalsBus.flame_hit_event.connect(self._on_flame_hit_event)

func _on_player_hit_event() -> void:
	start_shake(30.0, 0.6, 30.0)

func _on_flame_feed_event() -> void:
	start_shake(6.0, 0.9, 10.0)

func _on_flame_hit_event() -> void:
	start_shake()


func start_shake(magnitude: float = default_magnitude, duration: float = default_duration, frequency: float = default_frequency) -> void:
	_magnitude = magnitude
	_frequency = frequency
	_remaining = duration
	_time_since_update = 0.0
	_update_interval = 1.0 / max(frequency, 0.001) # how often targets change
	_generate_new_targets()

func stop_shake() -> void:
	_remaining = 0.0
	_reset()

func _process(delta: float) -> void:
	if _remaining > 0.0:
		_remaining = max(_remaining - delta, 0.0)
		var progress: float = 1.0 - (_remaining / max(default_duration, 0.0001))
		var falloff := 1.0 - ease_out_quad(progress)

		_time_since_update += delta
		if _time_since_update >= _update_interval:
			_time_since_update = 0.0
			_generate_new_targets()

		# interpolate current toward target for smoothness
		var interp_t: float = clamp(delta * _frequency * 0.5, 0.0, 1.0)
		_current_offset = _current_offset.lerp(_target_offset * falloff, interp_t)
		offset = _original_offset + _current_offset

		if enable_rotation:
			_current_rotation = lerp(_current_rotation, _target_rotation * falloff, interp_t)
			rotation_degrees = _original_rotation + _current_rotation
	else:
		_reset()

func _generate_new_targets() -> void:
	# random directional shake in circle
	var angle := _rng.randf_range(0.0, TAU)
	var radius := _rng.randf_range(0.0, 1.0)
	_target_offset = Vector2(cos(angle), sin(angle)) * radius * _magnitude
	if enable_rotation:
		_target_rotation = _rng.randf_range(-1.0, 1.0) * max_rotation_degrees

func _reset_internal() -> void:
	_current_offset = Vector2.ZERO
	_target_offset = Vector2.ZERO
	_current_rotation = 0.0
	_target_rotation = 0.0
	offset = _original_offset
	rotation_degrees = _original_rotation

func _reset() -> void:
	_reset_internal()

func ease_out_quad(t: float) -> float:
	return 1.0 - (1.0 - t) * (1.0 - t)
