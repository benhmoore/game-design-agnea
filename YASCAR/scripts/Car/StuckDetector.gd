extends Node3D

enum ControlScheme { ARROWS, WASD }
var control_scheme:ControlScheme

@onready var car = get_parent()

var actions:Array = []
var prev_action
var prev_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	prev_position = global_position
	control_scheme = car.control_scheme


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var action_label = ""

	# If control scheme is WASD, then detect key presses and add them to the actions array
	if control_scheme == ControlScheme.WASD:
		if Input.is_action_pressed("move_forward"):
			action_label = "up"
		if Input.is_action_pressed("move_backward"):
			action_label = "down"

	# If control scheme is ARROWS, then detect key presses and add them to the actions array
	if control_scheme == ControlScheme.ARROWS:
		if Input.is_action_pressed("ui_up"):
			action_label = "up"
		if Input.is_action_pressed("ui_down"):
			action_label = "down"
	
	if action_label != "": # Make sure an input is pressed
		if prev_action != action_label:
			actions.append([action_label, global_position])
			prev_action = action_label

	if len(actions) > 3:
		
		print(actions)
		
		# Check if all stored positions are the same
		if snapped(actions[0][1].x, 0.01) == snapped(actions[1][1].x, 0.01) and snapped(actions[1][1].x, 0.01) == snapped(actions[2][1].x, 0.01) and snapped(actions[0][1].z, 0.01) == snapped(actions[1][1].z, 0.01) and snapped(actions[1][1].z, 0.01) == snapped(actions[2][1].z, 0.01):
			
			car.reset_car()
			print("Resetting car's position!")

		actions.clear()
