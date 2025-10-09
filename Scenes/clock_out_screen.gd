extends Node2D

func _ready():
	var score = GlobalVariables.space_filled - GlobalVariables.free_space * 1.2
	if score > 0:
		$"Score Text".text = "You have been payed $" + str(score)
	else:
		$"Score Text".text = "You have been fined $" + str(-1*score)
	
	$"Crates shipped text".text = "You shipped " + str(-1*GlobalVariables.space_filled) + " Boxes Today"
	$"Empty Space text".text = str(GlobalVariables.free_space) + " More boxes could have been packed into the truck. This is coming out of your pay."
	
