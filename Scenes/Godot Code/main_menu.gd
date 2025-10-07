extends Node

func _ready():
	GlobalVariables.Diagetic_music = 0
	load("res://Scenes/music_player.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings_Menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().exit()


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_Game.tscn")
