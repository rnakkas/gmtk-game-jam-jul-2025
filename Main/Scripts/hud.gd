extends Control
class_name Hud

@onready var kindling_count_label: Label = %kindling_count
@onready var flame_hp_label: Label = %flame_hp
@onready var kill_count_label: Label = %kill_count

func _ready() -> void:
	SignalsBus.game_started_event.connect(self._on_game_started_event)
	SignalsBus.flame_hp_updated_event.connect(self._on_flame_hp_updated_event)

func _on_game_started_event(game_instance: Node2D) -> void:
	if game_instance is Game:
		kindling_count_label.text = str(game_instance.kindling_count)
		flame_hp_label.text = str(game_instance.flame_hp)
		kill_count_label.text = str(game_instance.kill_count)
	

func _on_flame_hp_updated_event(flame_hp: int) -> void:
	flame_hp_label.text = str(flame_hp)