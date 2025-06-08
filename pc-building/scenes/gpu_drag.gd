extends StaticBody3D



@onready var camera = $"GPU RX580/Camera"
@onready var gpu = $"GPU RX580"

var dragging = false
var drag_offset: Vector3
var drag_plane = Plane(Vector3.UP, 0)

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var query = PhysicsRayQueryParameters3D.create(from, to)
				query.collision_mask = 1
				query.exclude = []
				var result = get_world_3d().direct_space_state.intersect_ray(query)

				if result and result.collider == gpu:
					dragging = true
					drag_offset = gpu.global_transform.origin - result.position
			else:
				dragging = false

func _process(_delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

		var intersection = drag_plane.intersects_ray(from, to)
		if intersection:
			gpu.global_transform.origin = intersection + drag_offset
