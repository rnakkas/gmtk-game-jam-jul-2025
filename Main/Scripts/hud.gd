extends Control
class_name Hud

@onready var kindling_icon: TextureRect = %kindling_icon
@onready var kindling_count_label: Label = %kindling_count
@onready var flame_hp_label: Label = %flame_hp
@onready var kill_count_label: Label = %kill_count

func _ready() -> void:
	kindling_icon.visible = false
	# SignalsBus.kill_count_updated_event.connect(self._on_kill_count_updated_event)
	# SignalsBus.flame_hp_updated_event.connect(self._on_flame_hp_updated_event)
	# SignalsBus.kindling_count_updated_event.connect(self._on_kindling_count_updated_event_event)
	SignalsBus.kindling_picked_up_event.connect(self._on_kindling_picked_up)
	SignalsBus.player_delivered_kindling_event.connect(self._on_kindling_delivered)
	SignalsBus.player_death_event.connect(self._on_player_death)

# func _on_kill_count_updated_event(count: int) -> void:
# 	kill_count_label.text = str(count)

# func _on_flame_hp_updated_event(flame_hp: int) -> void:
# 	flame_hp_label.text = str(flame_hp)

# func _on_kindling_count_updated_event_event(count: int) -> void:
# 	kindling_count_label.text = str(count)

func _on_kindling_picked_up() -> void:
	kindling_icon.visible = true

func _on_kindling_delivered(_count) -> void:
	kindling_icon.visible = false

func _on_player_death(_pos) -> void:
	kindling_icon.visible = false