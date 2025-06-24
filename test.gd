extends Camera3D

@export var grid_size : int = 1
const RAY_LENGTH = 1000
@onready var ray = $RayCast3D
var current_box : CharacterBody3D
var target_position : Vector3
var moving =  false
var direction = Vector3.ZERO
var box_scene = load("res://Scenes/Boxes.tscn")

func _ready():
	call_deferred("setup")

	
func setup():
	current_box = ray.get_collider()
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

func _process(delta):
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
			current_box = selected_box
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
