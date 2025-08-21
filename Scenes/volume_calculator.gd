#How I think to get work, have code run for each instance of area 3d. Ask teacher if that method is imoptimsed

class_name Area3DCollisionChecker

# Static function to recursively find all Area3D children in a node tree
static func find_area3d_children(parent_node: Node) -> Array[Area3D]:
	var areas: Array[Area3D] = []
	_find_areas_recursive(parent_node, areas)
	return areas

# Static helper function for recursive area finding
static func _find_areas_recursive(node: Node, areas: Array[Area3D]) -> void:
	for child in node.get_children():
		if child is Area3D:
			areas.append(child as Area3D)
		_find_areas_recursive(child, areas)

# Static function to check collisions between Area3D nodes and a specific group
# Returns a dictionary with collision statistics and details
static func check_area_group_collisions(parent_node: Node, target_group: String = "Box", print_results: bool = true) -> Dictionary:
	# Find all Area3D nodes
	var areas = find_area3d_children(parent_node)
	
	var colliding_areas: Array[Area3D] = []
	var non_colliding_areas: Array[Area3D] = []
	
	if print_results:
		print("Checking ", areas.size(), " Area3D nodes for overlapping areas in '", target_group, "' group...")
	
	for area in areas:
		# Get all areas currently overlapping this area
		var overlapping_areas = area.get_overlapping_areas()
		
		# Check if any overlapping area is in the target group
		var has_group_collision = false
		for overlapping_area in overlapping_areas:
			if overlapping_area.is_in_group(target_group):
				has_group_collision = true
				break
		
		if has_group_collision:
			colliding_areas.append(area)
			if print_results:
				print("Area '", area.name, "' is overlapping with ", target_group, " group areas")
		else:
			non_colliding_areas.append(area)
	
	# Prepare results
	var results = {
		"total_areas": areas.size(),
		"colliding_count": colliding_areas.size(),
		"non_colliding_count": non_colliding_areas.size(),
		"colliding_areas": colliding_areas,
		"non_colliding_areas": non_colliding_areas,
		"target_group": target_group
	}
	
	if print_results:
		print("=== OVERLAP SUMMARY ===")
		print("Areas overlapping with ", target_group, " group: ", results.colliding_count)
		print("Areas NOT overlapping with ", target_group, " group: ", results.non_colliding_count)
		print("Total areas checked: ", results.total_areas)
	
	return results

# Static convenience function - simple version that just checks and prints results
static func check_box_collisions(parent_node: Node) -> void:
	check_area_group_collisions(parent_node, "Box", true)

# Static convenience function - get detailed results without printing
static func get_collision_data(parent_node: Node, group_name: String) -> Dictionary:
	return check_area_group_collisions(parent_node, group_name, false)

# Static convenience function - get only the names of colliding areas
static func get_colliding_area_names(parent_node: Node, group_name: String) -> Array[String]:
	var results = check_area_group_collisions(parent_node, group_name, false)
	var names: Array[String] = []
	for area in results.colliding_areas:
		names.append(area.name)
	return names
