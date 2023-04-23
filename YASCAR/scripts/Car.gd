extends CharacterBody3D

# Adjust these values as needed
const MAX_SPEED = 10 # Maximum linear speed in m/s
const ACCELERATION = 4  # How fast the car can accelerate in m/s^2
const BRAKE_FORCE = 10 # How fast the car can decelerate in m/s^2
@export var turning_speed = 3.5 # How fast the car can turn in rad/s

var linear_velocity = Vector3.ZERO # The current linear velocity of the car

@onready var tire_left:Node3D = $tire_left
@onready var tire_right:Node3D = $tire_right
@onready var current_direction: Marker3D = $CurrentDirection

@onready var tire_forward_ray: RayCast3D = $TireForwardRay
@onready var direction_ray: Node3D = $ForwardDirection


func _physics_process(delta):
	
	# Set tire rotations
	tire_forward_ray.look_at(current_direction.global_position)
	tire_left.rotation.y = tire_forward_ray.rotation.y + deg_to_rad(-270)
	tire_right.rotation.y = tire_forward_ray.rotation.y + deg_to_rad(-90)
	
#	rotation.y = tire_forward_ray.rotation.y + deg_to_rad(180)

	# Get the input values from the WASD keys or the controller joystick
	var input_y = Input.get_axis("ui_up", "ui_down")
	var input_x = Input.get_axis("ui_left", "ui_right")

	# Get the forward direction of the forward_ray in global space
	var forward = -transform.basis.z

	# Apply acceleration or deceleration depending on the input
	if input_y != 0:
		# Accelerate along the forward direction of the forward_ray
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

	var new_rot = 0
	if input_x != 0:
		# Calculate rotation
		new_rot = -input_x * turning_speed/5 * delta

		# Rotation should be inversely proportional to the speed
	#	new_rot *= (1 - linear_velocity.length() / MAX_SPEED)

		# If the car is not moving, don't rotate
		if linear_velocity.length() == 0:
			new_rot = 0

	rotate_y(new_rot)
	
	# Set the velocity and up direction properties of the node
	velocity = linear_velocity
	up_direction = Vector3.UP
	
	# Move and slide the car body along the velocity vector
	var collided = move_and_slide()
