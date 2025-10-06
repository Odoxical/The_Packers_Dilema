extends Node
var space_filled = 0
var time_taken = 0
var Diagetic_music = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Diagetic_music >= 2:
		Diagetic_music = 0
	
