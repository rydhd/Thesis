extends MeshInstance3D

@onready var camera: Camera3D = get_node("../../../MeshCam")
@onready var area: Node3D = get_node("../../../Area3D")
@onready var indicator: MeshInstance3D = get_node("../../../SnapIndicator")

var is_dragging := false
var drag_offset := Vector3.ZERO

func _ready():
	indicator.visible = true # Always visible and stays fixed

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
				if result and result.collider == area:
					print("Started dragging at:", result.position)
					is_dragging = true
					drag_offset = area.global_position - result.position
				else:
					print("Clicked something else:", result.collider.name)


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
			var snapped = (result.position + drag_offset).snapped(Vector3.ONE)
			area.global_position = snapped
			# Removed: indicator.global_position = snapped
