extends CanvasLayer

# This function runs when the "BackButton" is clicked
func _on_back_button_pressed():
	# Replace with the actual path to YOUR 2D scene
	var err = get_tree().change_scene_to_file("res://scenes/shop_2d.tscn")
	
	# Optional: Good practice to check for errors
	if err != OK:
		push_error("Couldn't load 2D scene! Check the path.")
