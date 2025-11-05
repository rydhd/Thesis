# DialogueSystem.gd
extends Control

# 1. Define the signals that this scene can send out.
signal accepted
signal declined

# 2. Get references to the buttons.
@onready var accept_button = $VBoxContainer/AcceptButton # Adjust path if not using VBoxContainer
@onready var decline_button = $VBoxContainer/DeclineButton # Adjust path if not using VBoxContainer
@onready var label = $VBoxContainer/DialogueLabel # Adjust path if not using VBoxContainer


func _ready():
	# 3. Connect the buttons' pressed signals to functions IN THIS SCRIPT.
	accept_button.pressed.connect(_on_accept_pressed)
	decline_button.pressed.connect(_on_decline_pressed)
	
	# Start hidden
	visible = false


func show_dialogue(text_to_display: String):
	label.text = text_to_display
	visible = true


func hide_dialogue():
	visible = false


# 4. This function runs when the AcceptButton is clicked.
func _on_accept_pressed():
	print("DialogueSystem: Accept pressed. Emitting signal.")
	hide_dialogue()
	accepted.emit() # This sends the "accepted" signal out to any listener.


# 5. This function runs when the DeclineButton is clicked.
func _on_decline_pressed():
	print("DialogueSystem: Decline pressed. Emitting signal.")
	hide_dialogue()
	declined.emit() # This sends the "declined" signal out.
