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

static func check_box_vs_world_collisions(box_container_node: Node, print_results: bool = true) -> Dictionary:
	# Find all Area3D nodes in the box container (these are the box detectors)
	var box_areas = find_area3d_children(box_container_node)
	
	# Find all Area3D nodes in the scene that are NOT in the box container
	var scene_root = box_container_node.get_tree().current_scene
	var all_areas = find_area3d_children(scene_root)
	var world_areas: Array[Area3D] = []
	
	# Filter out box areas to get only world/level areas
	for area in all_areas:
		var is_box_area = false
		# Check if this area is a descendant of box_container_node
		var check_node = area
		while check_node != null:
			if check_node == box_container_node:
				is_box_area = true
				break
			check_node = check_node.get_parent()
		
		if not is_box_area:
			world_areas.append(area)
	
	if print_results:
		print("Checking ", box_areas.size(), " box areas against ", world_areas.size(), " world areas...")
	
	var collision_results = {}
	var boxes_with_collisions = []
	var world_areas_with_collisions = []
	var world_areas_without_collisions = []
	
	# Check each world area to see if any boxes are overlapping it
	for world_area in world_areas:
		var overlapping_areas = world_area.get_overlapping_areas()
		var colliding_boxes = []
		
		# Check if any overlapping areas are box areas
		for overlapping_area in overlapping_areas:
			if overlapping_area in box_areas:
				colliding_boxes.append(overlapping_area)
				if overlapping_area not in boxes_with_collisions:
					boxes_with_collisions.append(overlapping_area)
		
		if colliding_boxes.size() > 0:
			world_areas_with_collisions.append(world_area)
			collision_results[world_area.name] = colliding_boxes
			if print_results:
				var box_names = []
				for box in colliding_boxes:
					box_names.append(box.name)
				print("World area '", world_area.name, "' has collision with boxes: ", box_names)
		else:
			world_areas_without_collisions.append(world_area)
	
	# Prepare results
	var results = {
		"total_box_areas": box_areas.size(),
		"total_world_areas": world_areas.size(),
		"boxes_with_collisions": boxes_with_collisions,
		"world_areas_with_collisions": world_areas_with_collisions,
		"world_areas_without_collisions": world_areas_without_collisions,
		"collision_details": collision_results
	}
	
	if print_results:
		print("=== COLLISION SUMMARY ===")
		print("Total boxes checked: ", results.total_box_areas)
		print("Total world areas checked: ", results.total_world_areas)
		print("World areas WITH box collisions: ", results.world_areas_with_collisions.size())
		print("World areas WITHOUT box collisions: ", results.world_areas_without_collisions.size())
		print("Boxes involved in collisions: ", results.boxes_with_collisions.size())
		
		if results.world_areas_without_collisions.size() > 0:
			print("World areas with no collisions:")
			for area in results.world_areas_without_collisions:
				print("  - ", area.name)
	
	return results

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
