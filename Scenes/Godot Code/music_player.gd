extends Node

var change_check = 0

func _ready() -> void:
	GlobalVariables.Diagetic_music = 1
#	play_music()

#func play_music():
#	if GlobalVariables.Diagetic_music != change_check:
#		get_tree().get_node($Diagetic).stop()
#		get_tree().get_node($Non_diagetic).stop()
#		print("Stop work")
#		if GlobalVariables.Diagetic_music == 1:
#			get_tree().get_node($Diagetic).play
#			print("start work")
#		if GlobalVariables.Diagetic_music == 0:
#			get_tree().get_node($Non_diagetic).play()
