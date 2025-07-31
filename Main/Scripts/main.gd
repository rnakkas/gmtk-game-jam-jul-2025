extends Node2D
class_name Main

func _input(_event: InputEvent) -> void:
	if !OS.is_debug_build():
		return
	if Input.is_key_label_pressed(KEY_Q): # quit game
		get_tree().quit()
	
	if Input.is_key_label_pressed(KEY_R): # reset game
		get_tree().paused = false
		get_tree().reload_current_scene()
