extends Node3D
var trucks_left = 0



func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Ui/Clock Out Screen.tscn")
