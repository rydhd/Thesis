# This script should be attached to the Area3D node.
extends Area3D

# Note: The node paths are shorter now because we are higher up in the tree.
@onready var camera: Camera3D = get_node("../MeshCam")
@onready var indicator: MeshInstance3D = get_node("../SnapIndicator")
# We no longer need the @export var for the area, because THIS script IS on the area.

var is_selected := false

func _ready():
	indicator.visible = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var mouse_pos = event.position
		var origin = camera.project_ray_origin(mouse_pos)
		var direction = camera.project_ray_normal(mouse_pos)
		var to = origin + direction * 1000.0

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, to)
		var result = space_state.intersect_ray(query)

		# The core selection logic is now simpler and more robust!
		# We check if the thing the ray hit is 'self' (this Area3D node).
		if result and result.collider == self:
			is_selected = true
			indicator.visible = true
			print("Object selected!")
		else:
			is_selected = false
			indicator.visible = false
