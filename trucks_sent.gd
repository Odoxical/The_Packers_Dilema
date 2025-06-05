extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Trucks sent".text = str("You have sent", res://Main_Menu.tscn.trucks_left, "Trucks on their way")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
