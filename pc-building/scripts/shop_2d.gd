extends Node2D
# Shop_2d.gd

# Preload the NPC scene so Godot loads it once when the game starts, 
# improving performance when we instance it later.
const NPC_SCENE = preload("res://scenes/NpcCustomer.tscn")

@onready var npc_spawn_position: Marker2D = $NpcSpawnPoint # Assuming you add a Marker2D in your scene editor
@onready var dialogue_system = $DialogueSystem # Assuming you have a node to manage dialogue UI

# Tracks the current NPC instance
var current_npc: Area2D = null 

# _ready() runs ONCE when the node is added to the scene.
# This is the correct place to connect signals.
func _ready():
	# Connect to the signals from your DialogueSystem node.
	# When dialogue_system emits "accepted", call our "_on_dialogue_accepted" function.
	dialogue_system.accepted.connect(_on_dialogue_accepted)
	
	# When dialogue_system emits "declined", call our "_on_dialogue_declined" function.
	dialogue_system.declined.connect(_on_dialogue_declined)


func start_npc_dialogue():
	# This function is called when the NPC is ready for dialogue.
	
	print("NPC fade-in finished, starting dialogue!")
	
	if is_instance_valid(dialogue_system):
		# This is the line that calls your DialogueSystem script
		dialogue_system.show_dialogue("Hello, what can I help you with?")
	else:
		print("ERROR: Dialogue system node is not valid!")


# This function name must match the signal connection from your Button!
func _on_button_pressed() -> void:
	print("Bell pressed! Attempting to spawn NPC.")
	
	# Don't spawn a new NPC if one is already present.
	if is_instance_valid(current_npc):
		print("NPC already here, starting dialogue instead.")
		start_npc_dialogue()
		return

	# --- 1. Spawn the NPC ---
	current_npc = NPC_SCENE.instantiate()
	
	# --- 2. Set Scale (if you still need this) ---
	var desired_scale = Vector2(0.3, 0.3) # Or whatever scale you chose
	current_npc.scale = desired_scale
	
	# Add the NPC to the scene tree.
	$NpcLayer.add_child(current_npc)

	# --- 3. Set Position DIRECTLY ---
	# We no longer start off-screen. Set its position directly
	# to the spawn point, since it will be invisible anyway.
	current_npc.global_position = npc_spawn_position.global_position
	
	# --- 4. Start Fade-in and Connect Signal ---
	
	# Call the new fade-in function on the NPC script.
	current_npc.fade_in_and_signal()
	
	# We connect the NPC's NEW signal to our dialogue function.
	# Make sure this matches the signal name in NpcCharacter.gd!
	current_npc.fade_in_complete.connect(start_npc_dialogue)
	
	# That's it! No more movement logic needed here.


func _on_dialogue_accepted():
	print("Shop2d: Received 'accepted' signal. Changing to 3D scene!")
	
	# --- THIS IS THE SCENE CHANGE CODE ---
	# Make sure you create a 3D scene and update this path!
	var error = get_tree().change_scene_to_file("res://scenes/repair_3d.tscn")
	
	if error != OK:
		print("ERROR: Could not change scene. Check the file path.")


# This function is called automatically when the "declined" signal is received.
func _on_dialogue_declined():
	print("Shop2d: Received 'declined' signal. Player declined.")
	# The dialogue box is already hidden. We can just... do nothing!
	# Or maybe have the NPC fade out. For now, just a print is fine.
	
	# (Optional) If you want the NPC to leave after being declined:
	# if is_instance_valid(current_npc):
	#	 current_npc.queue_free()
	#	 current_npc = null
