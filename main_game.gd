extends Node3D



func _on_timer_timeout() -> void:
	get_viewport().change_scene_to_file("res://Ui/Clock Out Screen.tscn")
