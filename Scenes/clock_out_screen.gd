extends Node2D

func _ready():
	var score = GlobalVariables.space_filled - GlobalVariables.empty_space * 10 ##This only doesn't complain If I dont use the proper -=.
	$"Score Text".text = "You have been payed $" + score
	$"Crates shipped text".text = "You shipped" + GlobalVariables.space_filled + "Boxes Today"
	$"Empty Space text".text = GlobalVariables.empty_space + "More boxes could have been packed into the truck. This is coming out of your pay."
