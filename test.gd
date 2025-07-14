extends Camera3D

@export var grid_size : int = 1
const RAY_LENGTH = 1000
@onready var ray = $RayCast3D
var current_box : CharacterBody3D
var target_position : Vector3
var target_rotation : Vector3
var moving =  false
var rotating = false
var direction = Vector3.ZERO
var box_scene = load("res://Scenes/Boxes.tscn")


func _ready():
	call_deferred("setup")

	
func setup():
	var collider = ray.get_collider()
	if collider is CharacterBody3D:
		current_box = collider
	else:
		print("No CharacterBody3D hit by raycast")
		print(current_box)

func V2toV3(vector):
	return Vector3(vector.x,vector.y,0)

func snap_to_nearest_axis(vector: Vector3) -> Vector3: #This all is to stop diagonal Movement
	if vector == Vector3.ZERO:
		return Vector3.ZERO
	var abs_x = abs(vector.x)
	var abs_y = abs(vector.y)
	var abs_z = abs(vector.z)
	var max_component = max(abs_x, abs_y, abs_z)
	
	if max_component == abs_x:
		return Vector3(sign(vector.x), 0, 0)
	elif max_component == abs_y:
		return Vector3(0, sign(vector.y), 0)
	else:
		return Vector3(0, 0, sign(vector.z))

# NEW COLLISION DETECTION FUNCTION - WITH MARGIN
func check_collision_in_direction(direction: Vector3) -> bool:
	if not current_box:
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	# Find the first CollisionShape3D in the current box
	var collision_shape_node = null
	for child in current_box.get_children():
		if child is CollisionShape3D:
			collision_shape_node = child
			break
	
	if not collision_shape_node or not collision_shape_node.shape:
		print("No CollisionShape3D found in current_box")
		return false
	
	# Create shape query
	var query = PhysicsShapeQueryParameters3D.new()
	query.collision_mask = current_box.collision_mask
	query.shape = collision_shape_node.shape
	query.exclude = [current_box.get_rid()]  # Exclude current box from collision check
	query.margin = 0.01  # Small margin to avoid touching-face collisions
	
	# Set the transform to the target position
	query.transform = current_box.global_transform
	query.transform.origin += direction
	
	# Check for intersections
	var result = space_state.intersect_shape(query)
	
	if result.size() > 0:
		print("Collision detected! Would hit: ", result[0].collider)
		return true
	
	return false

# ALTERNATIVE: RAYCAST METHOD FOR TOUCHING FACES
func check_collision_with_raycast(direction: Vector3) -> bool:
	if not current_box:
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	# Cast a ray slightly ahead of the box
	var ray_start = current_box.global_position
	var ray_end = ray_start + direction * 1.1  # Slightly further than one grid unit
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [current_box.get_rid()]
	query.collision_mask = current_box.collision_mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Ray collision detected! Would hit: ", result.collider)
		return true
	
	return false

# HYBRID APPROACH: SHAPE CAST WITH OFFSET
func check_collision_with_offset(direction: Vector3) -> bool:
	if not current_box:
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	# Find the first CollisionShape3D in the current box
	var collision_shape_node = null
	for child in current_box.get_children():
		if child is CollisionShape3D:
			collision_shape_node = child
			break
	
	if not collision_shape_node or not collision_shape_node.shape:
		print("No CollisionShape3D found in current_box")
		return false
	
	# Create shape query with a small offset into the movement direction
	var query = PhysicsShapeQueryParameters3D.new()
	query.collision_mask = current_box.collision_mask
	query.shape = collision_shape_node.shape
	query.exclude = [current_box.get_rid()]
	
	# Move the shape slightly further than the target position
	query.transform = current_box.global_transform
	query.transform.origin += direction * 1.1  # 10% further than intended movement
	
	# Check for intersections
	var result = space_state.intersect_shape(query)
	
	if result.size() > 0:
		print("Collision detected! Would hit: ", result[0].collider)
		return true
	
	return false

# ENHANCED COLLISION DETECTION FOR MULTIPLE COLLISION SHAPES
func check_collision_all_shapes(direction: Vector3) -> bool:
	if not current_box:
		return false
	
	var space_state = get_world_3d().direct_space_state
	
	# Check all CollisionShape3D children
	for child in current_box.get_children():
		if child is CollisionShape3D and child.shape:
			var query = PhysicsShapeQueryParameters3D.new()
			query.collision_mask = current_box.collision_mask
			query.shape = child.shape
			query.exclude = [current_box.get_rid()]
			
			# Account for the child's local transform
			var child_transform = current_box.global_transform * child.transform
			query.transform = child_transform
			query.transform.origin += direction
			
			var result = space_state.intersect_shape(query)
			if result.size() > 0:
				print("Collision detected with shape: ", child.name, " would hit: ", result[0].collider)
				return true
	
	return false

func smooth_rotate(axis: Vector3, angle: float): #Smooths rotation
	if rotating == true:
		return
	else:
		rotating = true
		var tween = create_tween() #Starts a new tweening
		var target_rotation = current_box.rotation + axis * angle
		tween.tween_property(current_box, "rotation", target_rotation, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT) #Selected node, What is changed?, how far you want to rotate, rotation speed, acell and decel curve speed.
		tween.tween_callback(func():rotating = false)

func _process(delta):
	if current_box and not moving:
		# Get input for all three axes
		var input_x = Input.get_axis("Move Left", "Move Right")
		var input_y = Input.get_axis("Move Down","Move Up")
		var input_z = Input.get_axis("Move Forward", "Move Backward")
		
		# Construct a 3D direction vector
		direction = Vector3(input_x, input_y, input_z).normalized() #If you press a directional Key
		direction = snap_to_nearest_axis(direction) #Than the direction to move is in this direction
		
		# CHECK FOR COLLISION BEFORE MOVING
		if direction != Vector3.ZERO:
			# Choose which collision detection method to use:
			# Option 1: Shape cast with margin (good for most cases)
			var collision_detected = check_collision_in_direction(direction)
			
			# Option 2: Raycast method (allows touching faces to slide)
			# var collision_detected = check_collision_with_raycast(direction)
			
			# Option 3: Shape cast with offset (more precise than margin)
			# var collision_detected = check_collision_with_offset(direction)
			
			# Option 4: Multiple collision shapes (more thorough)
			# var collision_detected = check_collision_all_shapes(direction)
			
			if not collision_detected:
				target_position = current_box.position + direction 
				moving = true #Box is moving
			else:
				print("Movement blocked by collision!")
		
		var rotationangle = deg_to_rad(90)
		
		if rotating == false:
			if Input.is_action_just_pressed("Rotate X"):
				smooth_rotate(Vector3(1, 0, 0), rotationangle)
			if Input.is_action_just_pressed("Rotate Y"):
				smooth_rotate(Vector3(0, 1, 0), rotationangle)
			if Input.is_action_just_pressed("Rotate Z"):
				smooth_rotate(Vector3(0, 0, 1), rotationangle)
		
	if moving:
		print("Moving box from", current_box.position, " to ", target_position) #Test Code
		current_box.position = current_box.position.move_toward(target_position, 3* delta) #Makes the boxes current position move towards the target in small increments
		if current_box.position == target_position: #If the box has reahed the posiston we want
			moving = false #Than stop the box from moving
	
	if Input.is_action_just_pressed("Stop Box Moving"):
		# Instantiate the boxes scene (just to access its children)
		var boxes_instance = box_scene.instantiate()
		# Get all children (assumed to be different box scenes as nodes)
		var box_templates = []
		for child in boxes_instance.get_children():
			box_templates.append(child.duplicate())
		
		if box_templates.size() > 0:
			# Pick a random box
			var selected_box = box_templates[randi() % box_templates.size()]
			# Add to main scene
			get_tree().get_root().add_child(selected_box)
			selected_box.global_position = Vector3(0, 2, -2)
			selected_box.reparent($"../Box Container")
			# Get the node
			current_box = selected_box.get_node("CharacterBody3D") as CharacterBody3D
			print(selected_box)
			moving = false



	if moving:
		print("Moving box from", current_box.position, " to ", target_position) #Testing
		current_box.position = current_box.position.move_toward(target_position, 3* delta) #Makes the boxes current position move towards the target in small increments
		if current_box.position == target_position: #If the box has reahed the posiston we want
			moving = false #Than stop the box from moving

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
