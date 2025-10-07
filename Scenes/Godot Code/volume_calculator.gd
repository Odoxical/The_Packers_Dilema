extends Node

# Change this to the parent node that contains your Area3D children
@export var parent_node: Node

var areas = []  # Store found areas

func _ready():
	# Find all areas at startup since they won't change
	if not parent_node:
		parent_node = self
	
	find_area_children(parent_node, areas)
	print("Found ", areas.size(), " Area3D nodes ready for collision checking")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		check_area_collisions()

func check_area_collisions():
	var colliding_count = 0
	var not_colliding_count = 0
	
	print("Checking ", areas.size(), " Area3D nodes for overlapping areas in 'Box' group...")
	
	for area in areas:
		# Get all areas currently overlapping this area
		var overlapping_areas = area.get_overlapping_areas()
		
		# Check if any overlapping area is in the "Box" group
		var has_box_collision = false
		for overlapping_area in overlapping_areas:
			if overlapping_area.is_in_group("Box"):
				has_box_collision = true
				break
		
		if has_box_collision:
			colliding_count += 1
			print("Area '", area.name, "' is overlapping with Box group areas")
		else:
			not_colliding_count += 1
	
	print("=== OVERLAP SUMMARY ===")
	print("Areas overlapping with Box group: ", colliding_count)
	print("Areas NOT overlapping with Box group: ", not_colliding_count)
	print("Total areas checked: ", areas.size())

# Recursively find all Area3D children
func find_area_children(node: Node, areas: Array):
	for child in node.get_children():
		if child is Area3D:
			areas.append(child)
		# Recursively check children
		find_area_children(child, areas)
