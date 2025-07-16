extends Camera3D

@export var grid_size : int = 1
@export var enable_collision_detection : bool = true  # Toggle for debugging
const RAY_LENGTH = 1000
@onready var ray = $RayCast3D
var current_box : CharacterBody3D
var current_area : Area3D  # Reference to the box's Area3D
var target_position : Vector3
var start_position : Vector3  # Store starting position for snap-back
var target_rotation : Vector3
var start_rotation : Vector3  # Store starting rotation for snap-back
var moving = false
var rotating = false
var direction = Vector3.ZERO
var box_scene = load("res://Scenes/Boxes.tscn")

func _ready():
	call_deferred("setup")

func setup():
	var collider = ray.get_collider()
	if collider is CharacterBody3D:
		current_box = collider
		print("Found CharacterBody3D: ", current_box)
		# Try to find Area3D child
		for child in current_box.get_children():
			if child is Area3D:
				current_area = child
				print("Found Area3D: ", current_area)
				break
		
		if not current_area:
			print("No Area3D found in CharacterBody3D children")
			# Try alternative names or paths
			var area_candidates = ["Area3D", "Area", "CollisionArea"]
			for candidate in area_candidates:
				if current_box.has_node(candidate):
					current_area = current_box.get_node(candidate) as Area3D
					print("Found Area3D with name: ", candidate)
					break
		
		if not current_area:
			print("WARNING: No Area3D found - collision detection will be disabled")
	else:
		print("No CharacterBody3D hit by raycast")
		print(current_box)

func V2toV3(vector):
	return Vector3(vector.x,vector.y,0)

func snap_to_nearest_axis(vector: Vector3) -> Vector3:
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

func check_collision() -> bool:
	# Check if current_area overlaps with any other areas
	if current_area and current_area.has_overlapping_areas():
		var overlapping_areas = current_area.get_overlapping_areas()
		# Filter out self-overlapping (if the same box has multiple areas)
		var valid_collisions = []
		for area in overlapping_areas:
			# Make sure we're not detecting collision with our own area or parent
			if area != current_area and area.get_parent() != current_box:
				valid_collisions.append(area)
		
		if valid_collisions.size() > 0:
			print("Collision detected with: ", valid_collisions)
			return true
	return false

func smooth_rotate(axis: Vector3, angle: float):
	if rotating == true:
		return
	else:
		rotating = true
		start_rotation = current_box.rotation  # Store starting rotation
		print("Starting rotation from: ", start_rotation)
		var tween = create_tween()
		var target_rotation = current_box.rotation + axis * angle
		tween.tween_property(current_box, "rotation", target_rotation, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(func():
			print("Rotation completed, checking collision...")
			# Check for collision after rotation completes
			if enable_collision_detection and check_collision():
				print("Rotation collision detected! Snapping back to start rotation")
				current_box.rotation = start_rotation
			else:
				print("No rotation collision detected")
			rotating = false
		)

func _process(delta):
	if current_box and current_area and not moving:
		# Get input for all three axes
		var input_x = Input.get_axis("Move Left", "Move Right")
		var input_y = Input.get_axis("Move Down","Move Up")
		var input_z = Input.get_axis("Move Forward", "Move Backward")
		
		# Construct a 3D direction vector
		direction = Vector3(input_x, input_y, input_z).normalized()
		direction = snap_to_nearest_axis(direction)
		
		if direction != Vector3.ZERO:  # Only move if there's input
			start_position = current_box.position  # Store starting position
			target_position = current_box.position + direction 
			moving = true
		
		var rotationangle = deg_to_rad(90)
		
		if rotating == false:
			if Input.is_action_just_pressed("Rotate X"):
				smooth_rotate(Vector3(1, 0, 0), rotationangle)
			if Input.is_action_just_pressed("Rotate Y"):
				smooth_rotate(Vector3(0, 1, 0), rotationangle)
			if Input.is_action_just_pressed("Rotate Z"):
				smooth_rotate(Vector3(0, 0, 1), rotationangle)
	
	if moving:
		print("Moving box from", current_box.position, " to ", target_position)
		current_box.position = current_box.position.move_toward(target_position, 3* delta)
		
		if current_box.position == target_position:
			moving = false
	
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
			
			# Debug: Print the structure of the spawned box
			print("Spawned box structure:")
			print("Selected box: ", selected_box)
			print("Children of selected box:")
			for child in selected_box.get_children():
				print("  - ", child.name, " (", child.get_class(), ")")
				for grandchild in child.get_children():
					print("    - ", grandchild.name, " (", grandchild.get_class(), ")")
			
			# Try to find CharacterBody3D - it might be the selected_box itself or a child
			if selected_box is CharacterBody3D:
				current_box = selected_box
			else:
				current_box = selected_box.get_node("CharacterBody3D") as CharacterBody3D
			
			if current_box:
				print("Found CharacterBody3D: ", current_box)
				# Try to find Area3D child
				for child in current_box.get_children():
					if child is Area3D:
						current_area = child
						print("Found Area3D: ", current_area)
						break
				
				if not current_area:
					print("No Area3D found in CharacterBody3D children")
					# Try alternative names or paths
					var area_candidates = ["Area3D", "Area", "CollisionArea"]
					for candidate in area_candidates:
						if current_box.has_node(candidate):
							current_area = current_box.get_node(candidate) as Area3D
							print("Found Area3D with name: ", candidate)
							break
			else:
				print("No CharacterBody3D found in spawned box")
			
			print("Final current_box: ", current_box)
			print("Final current_area: ", current_area)
			moving = false

func _physics_process(delta):
	# Handle collision detection in physics process where Area3D updates are current
	if moving and enable_collision_detection:
		print("Checking collision during movement...")
		if check_collision():
			print("Collision detected! Snapping back to start position")
			current_box.position = start_position
			moving = false
		else:
			print("No collision during movement")
	
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	# Your existing physics process code...
