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
var rotation_tween : Tween  # Store reference to the rotation tween
var direction = Vector3.ZERO
var box_scene = load("res://Scenes/Boxes.tscn")
var valid_collisions = []

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
	#all this code is just to stop diagonal movement
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
		if str(current_area.get_child(1)) == "Box Detector": ##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
			print("inside buildzone")##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
		else:
			
			var overlapping_areas = current_area.get_overlapping_areas()
			
			# Filter out self-overlapping (if the same box has multiple areas)
			var valid_collisions = []
			for area in overlapping_areas:
				if area != current_area and get_parent().is_in_group("No Colide"): ##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
					print("No collision necessary") ##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
					return false ##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
				# Make sure we're not detecting collision with our own area or parent
				elif area != current_area and area.get_parent() != current_box:
					valid_collisions.append(area)
			
			if valid_collisions.size() > 0:
				return true
			else:
				print("No valid collisions found (only self-overlapping)")
				return false
	return false

func smooth_rotate(axis: Vector3, angle: float):
	if rotating == true:
		return
	else:
		rotating = true
		
		# Store the starting transform for snap-back
		var start_transform = current_box.global_transform
		
		# Kill any existing rotation tween
		if rotation_tween:
			rotation_tween.kill()
		
		# Create rotation quaternion for the desired axis and angle
		var rotation_quat = Quaternion(axis, angle)
		
		# Calculate target transform by applying rotation in WORLD SPACE (not local space)
		# This means we apply the rotation BEFORE the current transform, not after
		var target_transform = Transform3D(Basis(rotation_quat) * start_transform.basis, start_transform.origin)
		
		rotation_tween = create_tween()
		
		# Interpolate between the current and target transforms using quaternions
		rotation_tween.tween_method(
			func(progress: float):
				# Interpolate the basis using quaternion slerp
				var current_quat = Quaternion(start_transform.basis)
				var target_quat = Quaternion(target_transform.basis)
				var interpolated_quat = current_quat.slerp(target_quat, progress)
				
				# Apply the interpolated rotation
				current_box.global_transform.basis = Basis(interpolated_quat)
				
				# Check collision during rotation if enabled
				if enable_collision_detection:
					if check_collision():
						print("Collision detected during rotation! Stopping and snapping back")
						rotation_tween.kill()
						current_box.global_transform = start_transform
						rotating = false
						return
				,
				0.0,
				1.0,
				0.5
			).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		
		# Add completion callback
		rotation_tween.tween_callback(func():
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
		current_box.position = current_box.position.move_toward(target_position, 3* delta)
		if current_box.position == target_position:
			moving = false
	
	if Input.is_action_just_pressed("Send out"): ##currently working on
		Area3DCollisionChecker.check_box_collisions($BoxContainer)
		print("=== DEBUGGING ===")
		var parent = current_box.get_parent()
		print("current_box: ", current_box)
		print("current_box is null: ", current_box == null)
		
		if current_box != null:
			print("current_box.name: ", current_box.name)
			print("current_box parent: ", parent)
			print("parent is null: ", parent == null)
		
		if parent != null:
			print("parent.name: ", parent.name)
			print("parent children count: ", parent.get_child_count())
			# Now try the collision check
			Area3DCollisionChecker.check_box_collisions(parent)
		else:
			print("ERROR: Parent is null!")
	else:
		print("ERROR: current_box is null!")
	
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
			
			moving = false

func _physics_process(delta):
	# Handle collision detection in physics process where Area3D updates are current
	if moving and enable_collision_detection:
		if check_collision():
			if "Box Detector" in str(current_area.name): ##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
				print("Box Detector Detected") #add code here later add code here later add code here later add code here later add code here later add code here later add code here later add code here later
				return ##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
			elif "Box Detector" not in str(current_area.name):##CODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEINGCODEING
				print(str(current_area.get_child(1)))
				current_box.position = start_position
				moving = false
			else:
				return
	
	# Note: Rotation collision checking is now handled in the tween callback
	
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
