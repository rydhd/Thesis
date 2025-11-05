extends Node3D

var grabbed_object = null
var grab_distance = 10
var mouse = Vector2()
const DIST = 1000 #Ray Max distance

# --- NEW SNAPPING VARS ---
@export var snap_distance_threshold: float = 0.5 
var valid_snap_target: Transform3D = Transform3D()
var is_snapped: bool = false


func _process(delta: float) -> void:
	if grabbed_object:
		var follow_pos = get_grab_position()
		var snap_group_name = ""
		
		if grabbed_object.is_in_group("pc_fan"):
			snap_group_name = "fan_snap_points"
		elif grabbed_object.is_in_group("psu"):
			snap_group_name = "psu_snap_points"
		
		# --- DEBUG ---
		if snap_group_name == "fan_snap_points":
			print("Holding object '", grabbed_object.name, "' which has no snap group.")

		var closest_point: Node3D = null
		var min_dist_sq: float = INF 
		is_snapped = false 
		valid_snap_target = Transform3D() 

		if snap_group_name != "":
			var snap_points = get_tree().get_nodes_in_group(snap_group_name)
			
			# --- DEBUG ---
			if snap_points.is_empty():
				print("ERROR: Looking for group '", snap_group_name, "' but found 0 nodes.")
			
			for point in snap_points:
				var dist_sq = follow_pos.distance_squared_to(point.global_position)
				if dist_sq < min_dist_sq:
					min_dist_sq = dist_sq
					closest_point = point

		var threshold_sq = snap_distance_threshold * snap_distance_threshold
		var target_position_for_grab = follow_pos 

		if closest_point and min_dist_sq < threshold_sq:
			# --- WE ARE SNAPPED! ---
			is_snapped = true
			valid_snap_target = closest_point.global_transform
			target_position_for_grab = closest_point.global_position
			
			# --- DEBUG ---
			print("SNAPPED to '", closest_point.name, "' (Distance: ", sqrt(min_dist_sq), ")")
			
		else:
			# --- DEBUG ---
			if closest_point:
				print("Following mouse. Closest point '", closest_point.name, "' is too far. (Distance: ", sqrt(min_dist_sq), ")")
			else:
				print("Following mouse. No snap points found or group not set.")


		# --- APPLY MOVEMENT ---
		if grabbed_object is RigidBody3D:
			lift_item(grabbed_object, target_position_for_grab, delta)
		else:
			if is_snapped:
				grabbed_object.global_transform = valid_snap_target
			else:
				grabbed_object.global_position = target_position_for_grab


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
					# --- SUCCESSFUL DROP ---
					# --- DEBUG ---
					print("--- DROP: SUCCESS ---")
					print("Component '", grabbed_object.name, "' snapped to valid location.")
					
					grabbed_object.global_transform = valid_snap_target 
					
					# TODO: Add your "installation" logic here
					
				else:
					# --- INVALID DROP ---
					# --- DEBUG ---
					print("--- DROP: FAIL ---")
					print("Component '", grabbed_object.name, "' dropped in an invalid location.")
					
					# TODO: Add logic to return the item
			
			# --- DEBUG ---
			if grabbed_object:
				print("Releasing object '", grabbed_object.name, "'.")
				
			grabbed_object = null 
			is_snapped = false

func get_mouse_world_pos(mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse,DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	var result = space.intersect_ray(params)
	
	if result.is_empty() == false:
		grabbed_object = result.collider
		# --- DEBUG ---
		print("--- GRABBED ---")
		print("Grabbed object: '", grabbed_object.name, "'")
		
	else:
		# --- DEBUG ---
		print("--- GRAB FAILED ---")
		print("Clicked on empty space.")


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
