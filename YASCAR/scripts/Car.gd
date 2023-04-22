extends CharacterBody3D

# Adjust these values as needed
const MAX_SPEED = 10 # Maximum linear speed in m/s
const ACCELERATION = 4  # How fast the car can accelerate in m/s^2
const BRAKE_FORCE = 10 # How fast the car can decelerate in m/s^2
const TURN_SPEED = 2 # How fast the car can turn in rad/s

var linear_velocity = Vector3.ZERO # The current linear velocity of the car

func _physics_process(delta):
	# Get the input values from the WASD keys or the controller joystick
	var input_y = Input.get_axis("ui_up", "ui_down")
	
	var forward = transform.basis.x
	
	# Apply acceleration or deceleration depending on the input
	if input_y != 0:
		# Accelerate along the forward direction of the car
		linear_velocity += forward * input_y * ACCELERATION * delta
	else:
		# Apply brake force if no input is given
		var brake = linear_velocity.normalized() * BRAKE_FORCE * delta
		if brake.length() > linear_velocity.length():
			# Stop completely if the brake force is greater than the current speed
			linear_velocity = Vector3.ZERO
		else:
			# Otherwise, reduce the speed by the brake force
			linear_velocity -= brake
	
	# Limit speed
	linear_velocity = linear_velocity.limit_length(MAX_SPEED)
	
	# Set the velocity and up direction properties of the node
	velocity = linear_velocity
	up_direction = Vector3.UP
	
	# Move and slide the car body along the velocity vector
	var collided = move_and_slide()
