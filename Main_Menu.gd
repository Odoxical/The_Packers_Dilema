extends Node

func _on_Start_button_pressed():
	get_tree().change_scene_to_file("res://Main_Game.tcn")

func _on_Settings_button_pressed():
	get_tree().change_scene_to_file("res://Settings_Menu.tcn")

func _on_exit_button_pressed():
	get_tree().quit()
