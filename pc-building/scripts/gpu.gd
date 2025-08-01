extends MeshInstance3D

@onready var camera: Camera3D = get_node("../../../MeshCam")
@onready var area: Node3D = get_node("../..") # Corrected path for Area3D
@onready var indicator: MeshInstance3D = get_node("../../../SnapIndicator") # Corrected path for SnapIndicator

# Export variables for drag boundaries
@export var min_x: float = -10.0 # Minimum X position
@export var max_x: float = 10.0  # Maximum X position
@export var min_y: float = 0.0   # Minimum Y position (e.g., ground level)
@export var max_y: float = 5.0   # Maximum Y position (e.g., ceiling limit)
@export var min_z: float = -10.0 # Minimum Z position
@export var max_z: float = 10.0  # Maximum Z position

@export var snap_distance_threshold: float = 2.0 # How close the object needs to be to snap

var is_dragging := false
var drag_offset := Vector3.ZERO

func _ready():
	# If the indicator is meant to be a fixed grid point, keep it visible.
	# If it's a dynamic snap target, its visibility might change.
	indicator.visible = true 

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = event.position
		var origin = camera.project_ray_origin(mouse_pos)
		var direction = camera.project_ray_normal(mouse_pos)
		var to = origin + direction * 1000.0

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, to)
		var result = space_state.intersect_ray(query)

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if result:
				print("Left click hit at:", result.position)

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if result and result.collider == area:
					print("Started dragging Area3D at:", result.position)
					is_dragging = true
					drag_offset = area.global_position - result.position
					Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				else:
					if result:
						print("Clicked something else:", result.collider.name)
					else:
						print("No collider hit.")

			elif event.is_released():
				is_dragging = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta):
	if is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mouse_pos)
		var direction = camera.project_ray_normal(mouse_pos)
		var to = origin + direction * 1000.0

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, to)
		var result = space_state.intersect_ray(query)

		if result:
			# Calculate the potential new position based on mouse and offset
			var potential_position = result.position + drag_offset

			# --- Snapping Logic ---
			var final_position: Vector3

			# Calculate distance to the SnapIndicator's position
			var distance_to_indicator = potential_position.distance_to(indicator.global_position)

			# If within snapping threshold, snap to indicator's position
			if distance_to_indicator <= snap_distance_threshold:
				final_position = indicator.global_position
				# Optional: You might want to provide visual feedback here
				# print("Snapped to indicator!")
			else:
				# Otherwise, just use the potential position (free drag)
				final_position = potential_position
			# --- End Snapping Logic ---

			# --- Apply Clamping ---
			final_position.x = clampf(final_position.x, min_x, max_x)
			final_position.y = clampf(final_position.y, min_y, max_y)
			final_position.z = clampf(final_position.z, min_z, max_z)
			# --- End Clamping ---

			# Update the Area3D's position
			area.global_position = final_position
			
			# Ensure the SnapIndicator's position is NOT updated by the dragging
			# if it's meant to be a fixed grid point.
			# If the indicator is *also* draggable and its position changes by other means,
			# then you'd handle that separately.
