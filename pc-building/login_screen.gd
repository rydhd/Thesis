extends Control

# --- UI element references ---
# In the Godot editor, you should rename the "EmailEdit" node to "CodeEdit" for clarity.
@onready var code_edit: LineEdit = $VBoxContainer/CodeEdit
@onready var password_edit: LineEdit = $VBoxContainer/PasswordEdit
@onready var login_button: Button = $VBoxContainer/LoginButton
@onready var login_request: HTTPRequest = $LoginRequest

const LOGIN_URL = "http://localhost:8080/api/auth/login"


func _ready() -> void:
	login_button.pressed.connect(_on_login_button_pressed)
	login_request.request_completed.connect(_on_login_request_completed)


func _on_login_button_pressed() -> void:
	# Get text from the input fields
	var code = code_edit.text
	var password = password_edit.text

	if code.is_empty() or password.is_empty():
		print("Student Code and Password cannot be empty.")
		return

	# Create the data payload with a "code" key
	var body_dict = {
		"code": code,
		"password": password
	}

	# Convert the dictionary to a JSON string
	var body_json_string = JSON.stringify(body_dict)
	var headers = ["Content-Type: application/json"]
	
	print("Attempting to log in with student code...")
	login_request.request(LOGIN_URL, headers, HTTPClient.METHOD_POST, body_json_string)


func _on_login_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Network error.")
		return

	if response_code == 200:
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		print("Login Successful!")
		print("Welcome, %s!" % json_data.userData.first_name)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		
	elif response_code == 401:
		print("Login Failed: Invalid student code or password.")
	else:
		print("An unknown error occurred. Status code: ", response_code)
