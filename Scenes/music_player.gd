extends Node

var change_check = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	if global_variables.diagetic_music != change_check:
#		get_node("Diagetic").stop()
#		get_node("Non_diagetic").stop()
#		if global_variables.diagetic_music == 1:
#			get_node("Diagetic").play()
#		if global_variables.diagetic_music == 0:
#			get_node("Non_diagetic").play()
