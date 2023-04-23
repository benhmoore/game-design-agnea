extends VehicleBody3D

# The acceleration force applied to the vehicle when pressing the up arrow
@export var acceleration = 250.0

# The brake force applied to the vehicle when pressing the down arrow
@export var break_force = 100.0

# The steering angle limit for the front wheels
@export var steer_limit = deg_to_rad(25)

# The top speed limit of the vehicle
@export var top_speed = 50.0  # You can set your desired top speed here

# The front wheels that are used for steering
@onready var front_wheels = [get_node("FrontLeftWheel"), get_node("FrontRightWheel")]

# The rear wheels that are used for traction
@onready var rear_wheels = [get_node("RearLeftWheel"), get_node("RearRightWheel")]

func _physics_process(delta):
	# Get the input values for acceleration, brake and steering
	var move_input = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var turn_input = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")

	# Apply the engine force to the rear wheels
	for wheel in rear_wheels:
		wheel.engine_force = -move_input * acceleration

	# Apply the steering angle to the front wheels
	for wheel in front_wheels:
		wheel.steering = turn_input * steer_limit

	# Limit the vehicle's top speed
	if linear_velocity.length() > top_speed:
		linear_velocity = linear_velocity.normalized() * top_speed
