extends MeshInstance3D

@onready var camera: Camera3D = get_node("../../../MeshCam")
@onready var area: Node3D = get_node("../../../Area3D")

var is_dragging := false
var drag_offset := Vector3.ZERO

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

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				if result:
					print("Started dragging at:", result.position)
					is_dragging = true
					drag_offset = area.global_position - result.position
			else:
				is_dragging = false
				print("Stopped dragging.")

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
			area.global_position = result.position + drag_offset
