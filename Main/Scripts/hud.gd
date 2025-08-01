extends Control
class_name Hud

@onready var kindling_count_label: Label = %kindling_count
@onready var flame_hp_label: Label = %flame_hp
@onready var kill_count_label: Label = %kill_count

func _ready() -> void:
	SignalsBus.kill_count_updated_event.connect(self._on_kill_count_updated_event)
	SignalsBus.flame_hp_updated_event.connect(self._on_flame_hp_updated_event)
	SignalsBus.kindling_count_updated_event.connect(self._on_kindling_count_updated_event_event)

func _on_kill_count_updated_event(count: int) -> void:
	kill_count_label.text = str(count)

func _on_flame_hp_updated_event(flame_hp: int) -> void:
	flame_hp_label.text = str(flame_hp)

func _on_kindling_count_updated_event_event(count: int) -> void:
	kindling_count_label.text = str(count)