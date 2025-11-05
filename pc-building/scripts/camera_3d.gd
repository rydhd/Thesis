extends Node3D

var grabbed_object = null
var grab_distance = 10
var mouse = Vector2()
const DIST = 1000 #Ray Max distance

# --- SNAPPING VARS ---
@export var snap_distance_threshold: float = 2.0 # Kept at 6.0
var valid_snap_target: Transform3D = Transform3D()
var is_snapped: bool = false

# --- NEW VAR TO FIX SCALE ---
var grabbed_object_scale: Vector3 = Vector3.ONE # Will store the fan's scale


func _process(delta: float) -> void:
	if not grabbed_object:
		return # Do nothing if we're not holding anything

	# --- Default position to follow
	var follow_pos = get_grab_position()

	# --- Find snap group
	var snap_group_name = ""
	if grabbed_object.is_in_group("pc_fan"):
		snap_group_name = "fan_snap_points"
	elif grabbed_object.is_in_group("psu"):
		snap_group_name = "psu_snap_points"
	
	# --- Find closest snap point
	var closest_point: Node3D = null
	var min_dist_sq: float = INF 
	is_snapped = false 
	valid_snap_target = Transform3D() 

	if snap_group_name != "":
		var snap_points = get_tree().get_nodes_in_group(snap_group_name)
		for point in snap_points:
			var dist_sq = follow_pos.distance_squared_to(point.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_point = point

	# --- Check if we are close enough to snap
	var threshold_sq = snap_distance_threshold * snap_distance_threshold
	
	if closest_point and min_dist_sq < threshold_sq:
		# --- WE ARE SNAPPED! ---
		is_snapped = true
		valid_snap_target = closest_point.global_transform
	
	# --- APPLY MOVEMENT ---
	if is_snapped:
		# --- HARD SNAP (FOR ALL NODE TYPES) ---
		# Force the object to the snap point's position and rotation
		grabbed_object.global_transform = valid_snap_target
		
		# --- THE FIX ---
		# Re-apply the scale we saved when we first grabbed the object
		grabbed_object.scale = grabbed_object_scale
		
	else:
		# --- NO SNAP - FOLLOW MOUSE ---
		if grabbed_object is RigidBody3D:
			# Use soft-grab physics
			lift_item(grabbed_object, follow_pos, delta)
		else:
			# Use hard-grab position
			grabbed_object.global_position = follow_pos


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
		
	if event is InputEventMouseButton:
		# "GRAB" logic (LMB Release)
		if event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			get_mouse_world_pos(mouse) 
			
		# "DROP" logic (RMB Release)
		elif event.pressed == false and event.button_index == MOUSE_BUTTON_RIGHT:
			if grabbed_object:
				if is_snapped:
					print("--- DROP: SUCCESS ---")
					# Final set just in case
					grabbed_object.global_transform = valid_snap_target
					grabbed_object.scale = grabbed_object_scale # Re-apply scale on drop
				else:
					print("--- DROP: FAIL ---")
			
			grabbed_object = null 
			is_snapped = false
			grabbed_object_scale = Vector3.ONE # Reset scale variable


func get_mouse_world_pos(mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var camera = get_viewport().get_camera_3d() # Get the camera
	var start = camera.project_ray_origin(mouse)
	var end = camera.project_position(mouse,DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	var result = space.intersect_ray(params)
	
	if result.is_empty() == false:
		grabbed_object = result.collider
		
		# --- SAVE DISTANCE (Fixes "pop" on grab) ---
		grab_distance = camera.global_position.distance_to(grabbed_object.global_position)
		
		# --- SAVE SCALE (Fixes "pop" on snap) ---
		grabbed_object_scale = grabbed_object.scale 
		
		print("--- GRABBED ---")
		print("Grabbed object: '", grabbed_object.name, "'")
		print("Setting grab distance to: ", grab_distance)
		print("Saving original scale: ", grabbed_object_scale) # New debug line
		
	else:
		print("--- GRAB FAILED ---")
		print("Clicked on empty space.")


#Get the position in the world you want to object to follow
func get_grab_position():
	return get_viewport().get_camera_3d().project_position(mouse,grab_distance)

func lift_item(item:RigidBody3D,target_position:Vector3,delta):
		var I = 500.0 
		var S = 20.0 
		var P = target_position - item.global_position
		var M = item.mass
		var V = item.linear_velocity
		var impulse = (I*P) - (S*M*V)
		item.apply_central_impulse(impulse * delta)
