extends VehicleBody3D

enum ControlScheme { ARROWS, WASD }

# Audio players
@onready var engine_player: AudioStreamPlayer = $EngineAudioPlayer
@onready var sound_effect_player: AudioStreamPlayer = $SoundEffectAudioPlayer

# Car color
@export var car_color: Color = Color(1, 0, 0)
@onready var car_mesh: MeshInstance3D = $CarBody/body

# Car camera
@onready var camera: Camera3D = $Camera3D

# Control scheme selection
@export var control_scheme:ControlScheme = ControlScheme.ARROWS

# Acceleration, braking, steering limit, and max speed parameters
@export var acceleration_force = 250.0
@export var braking_force = 100.0
@export var steering_limit = deg_to_rad(25)
@export var max_speed = 50.0

# Minimum and maximum FOV for the camera
@export var min_fov = 70.0
@export var max_fov = 110.0

# Front and rear wheels
@onready var front_wheels = [get_node("FrontLeftWheel"), get_node("FrontRightWheel")]
@onready var rear_wheels = [get_node("RearLeftWheel"), get_node("RearRightWheel")]

func _ready():
	set_car_color(car_color)  # Set the car's color to red
	engine_player.play()

func set_car_color(color: Color):
	var newMaterial = StandardMaterial3D.new() 
	newMaterial.albedo_color = color
	car_mesh.set_surface_override_material(1, newMaterial)
	
#	car_mesh.mesh.material.albedo_color = Color(0,1,0)
	

func _physics_process(delta):
	# Get input values for acceleration, braking, and steering
	var accel_input = get_acceleration_input()
	var steer_input = get_steering_input()

	# Apply engine force to rear wheels
	for wheel in rear_wheels:
		wheel.engine_force = -accel_input * acceleration_force

	# Apply steering angle to front wheels
	for wheel in front_wheels:
		wheel.steering = steer_input * steering_limit

	# Limit vehicle's top speed
	limit_top_speed()

	# Update camera FOV based on car's velocity
	update_camera_fov(delta)


func limit_top_speed():
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func get_acceleration_input() -> float:
	if control_scheme == ControlScheme.ARROWS:
		return Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	else:
		return Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")

func get_steering_input() -> float:
	if control_scheme == ControlScheme.ARROWS:
		return Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	else:
		return Input.get_action_strength("move_left") - Input.get_action_strength("move_right")

func update_camera_fov(delta):
	var speed_ratio = linear_velocity.length() / max_speed
	var target_fov = lerp(min_fov, max_fov, speed_ratio)
	camera.fov = lerp(camera.fov, target_fov, 5 * delta)
