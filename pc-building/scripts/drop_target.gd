# DropTarget.gd
extends Control

# This function checks if the thing being dragged is valid
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	print("DropTarget: Checking if data is valid...")
	return data is ItemResource

# This function runs when the user releases the mouse over this Control
func _drop_data(at_position: Vector2, data: Variant):
	print("DropTarget: Data drop detected!")
	
	# The 'data' is the ItemResource we returned from _get_drag_data
	var item_resource: ItemResource = data
	
	# Make sure the item has a 3D scene to spawn
	if not item_resource.item_scene:
		push_error("This item has no 3D scene to spawn!")
		return

	# --- This is the 2D-to-3D Raycast ---
	
	# 1. Get the viewport
	var vp = get_viewport()
	if not vp:
		push_error("Raycast failed: Could not get Viewport.")
		return
		
	# 2. Get the 3D world FROM THE VIEWPORT
	var world_3d = vp.get_world_3d()
	if not world_3d:
		push_error("Raycast failed: Could not get World3D from Viewport.")
		return
		
	# 3. Get the camera FROM THE VIEWPORT
	var camera: Camera3D = vp.get_camera_3d()
	if not camera:
		push_error("Raycast failed: Could not get Camera3D from Viewport.")
		return
		
	# 4. Get the physics state FROM THE WORLD
	var space_state = world_3d.direct_space_state
	if not space_state:
		push_error("Raycast failed: Could not get DirectSpaceState.")
		return

	# 'at_position' is the 2D mouse position
	var ray_origin = camera.project_ray_origin(at_position)
	var ray_end = ray_origin + camera.project_ray_normal(at_position) * 1000.0
	
	# Create the query
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	# Optional: Set a collision mask if you need one
	# query.collision_mask = 1 
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# We hit something!
		var spawn_position = result.position
		
		# Now, instantiate the 3D scene from the resource
		var new_item_instance = item_resource.item_scene.instantiate()
		
		# Add it to the main scene (get_parent() is the "PC" Node3D)
		get_parent().add_child(new_item_instance)
		
		# Set its 3D position to where the raycast hit
		new_item_instance.global_position = spawn_position
		
		print("Spawned ", item_resource.item_name, " at ", spawn_position)
	else:
		print("Dropped into empty space. Nothing to spawn on.")
