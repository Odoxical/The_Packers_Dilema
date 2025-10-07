extends Node

var diagetic_music = 1
var change_check = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if diagetic_music >= 2:#Toggle switch.
		diagetic_music = 0#Toggle switch.
	#if diagetic_music != change_check: #If there is an order to change music
		change_check = diagetic_music
		if diagetic_music == 1: #If music is set to Diagetic mode
			get_node("Non_diagetic").stop() #Stop previously playing music
			get_node("Diagetic").play() #play diagetic track
		if diagetic_music == 0: #If music is set to Non-diagetic mode
			get_node("Diagetic").stop() #Stop previously playing music
			get_node("Non_diagetic").play() #play Non-diagetic track
