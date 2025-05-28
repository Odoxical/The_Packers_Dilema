extends Node

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Main_Game.tscn")

func _on_exit_pressed() -> void:
	get_tree().exit()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Settings_Menu.tscn")
