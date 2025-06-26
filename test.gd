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

var boxes_scene = load("res://Scenes/boxes.tscn")

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
		
		target_position = current_box.position + direction 
		moving = true #Box is moving
		
		var rotationangle = deg_to_rad(90)
		
		if rotating == false:
			if Input.is_action_just_pressed("Rotate X"):
				smooth_rotate(Vector3(1, 0, 0), rotationangle)
			if Input.is_action_just_pressed("Rotate Y"):
				smooth_rotate(Vector3(0, 1, 0), rotationangle)
			if Input.is_action_just_pressed("Rotate Z"):
				smooth_rotate(Vector3(0, 0, 1), rotationangle)
		
	if moving:
		print("Moving box from", current_box.position, " to ", target_position) #Test Cide
		current_box.position = current_box.position.move_toward(target_position, 3* delta) #Makes the boxes current position move towards the target in small increments
		if current_box.position == target_position: #If the box has reahed the posiston we want
			moving = false #Than stop the box from moving
	
	if Input.is_action_just_pressed("Stop Box Moving"):
		# Instantiate the boxes scene (just to access its children)
		var boxes_instance = boxes_scene.instantiate()
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
			# Get the CharacterBody3D child node (assuming it's named "CharacterBody3D")
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


	#var origin = cam.project_ray_origin(mousepos)
	#var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	#var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true

	#var result = space_state.intersect_ray(query)
