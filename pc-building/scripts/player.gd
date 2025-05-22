extends CharacterBody2D

const SPEED = 100

func _physics_process(delta):
	player_movement()

func player_movement():
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Back"):
		velocity.y += 1
	if Input.is_action_pressed("Forward"):
		velocity.y -= 1

	velocity = velocity.normalized() * SPEED
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/repair_3d.tscn")
