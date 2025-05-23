extends Node2D

func _on_MainMenu_button_pressed():
	get_tree().change_scene_to_file("res://Main_Menu.tcn")
func _on_SliderVisibility_button_pressed():
	get_tree().Buttonsize.visible= false
