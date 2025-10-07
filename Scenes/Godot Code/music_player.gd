extends Node

var change_check = 0

func _ready() -> void:
	GlobalVariables.Diagetic_music = 1

func play_music():
	if GlobalVariables.Diagetic_music != change_check:
		get_node("Diagetic").stop()
		get_node("Non_diagetic").stop()
		if GlobalVariables.Diagetic_music == 1:
			get_node("Diagetic").play()
		if GlobalVariables.Diagetic_music == 0:
			get_node("Non_diagetic").play()
