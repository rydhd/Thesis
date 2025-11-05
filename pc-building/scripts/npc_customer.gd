# NpcCharacter.gd (Root node: Area2D)
extends Area2D

# Define a custom signal that the NPC will emit when its fade-in is complete.
signal fade_in_complete

# How long the fade-in should take (in seconds)
const FADE_IN_DURATION = 1.0 # 1 second

# This new function will be called by Shop2d right after spawning.
func fade_in_and_signal():
	# 1. Start the NPC as fully transparent.
	# The 'modulate' property tints the node and all its children (like the Sprite2D).
	# We set its alpha (a) channel to 0.
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	# 2. Create a Tween to handle the animation.
	# A Tween is the best node for animating properties over time.
	var tween = create_tween()

	# 3. Set up the Tween:
	# We tell it to animate the 'modulate' property of this node (self)
	# to be fully opaque (alpha = 1.0) over FADE_IN_DURATION seconds.
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), FADE_IN_DURATION)

	# 4. Connect the Tween's 'finished' signal.
	# When the animation is done, we'll call our _on_tween_finished function.
	tween.finished.connect(_on_tween_finished)

# This function is called automatically by the tween when it finishes.
func _on_tween_finished():
	print("NPC fade-in complete.")
	# Now we signal the main shop scene that the NPC is ready for dialogue.
	fade_in_complete.emit()
