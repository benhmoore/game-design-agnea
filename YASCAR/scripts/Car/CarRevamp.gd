extends VehicleBody3D

signal collision_detected

enum ControlScheme { ARROWS, WASD }
enum CarState { IDLE, MOVING_FORWARD, MOVING_REVERSE, BREAKING }

var car_state = CarState.IDLE
var time_in_current_state = 0.0

var car_state_labels = {
	CarState.IDLE: "IDLE",
	CarState.MOVING_FORWARD: "MOVING_FORWARD",
	CarState.MOVING_REVERSE: "MOVING_REVERSE",
	CarState.BREAKING: "BREAKING"
}

var airborne = false
var last_airborne_duration = 0.0
var airborne_timer = 0.0
var flip_count = 0

@export var idle_speed_threshold = 0.5

# Hit particles
@onready var hit_particles: CPUParticles3D = $Hit/CPUParticles3D

# For flip detection
var previous_euler_angles = Vector3()
var accumulated_rotation = Vector3()

# Audio players
@onready var engine_player: AudioStreamPlayer = $EngineAudioPlayer
@onready var sound_effect_player: AudioStreamPlayer = $SoundEffectAudioPlayer

# Car color
@export var car_color: Color = Color(1, 0, 0)
@onready var car_mesh: MeshInstance3D = $CarBody/body

# Car breaklights
var breaklights_on: bool = false
@onready var breaklight_left: SpotLight3D = $LeftBreaklight
@onready var breaklight_right: SpotLight3D = $RightBreaklight

# Car camera
@onready var camera: Camera3D = $Camera3D

# Control scheme selection
@export var control_scheme: ControlScheme = ControlScheme.ARROWS

# Acceleration, braking, steering limit, and max speed parameters
@export var acceleration_force = 150.0
@export var braking_force = 100.0
@export var steering_limit = deg_to_rad(10)
@export var max_speed = 30.0

# Minimum and maximum FOV for the camera
@export var min_fov = 70.0
@export var max_fov = 110.0

# Front and rear wheels
@onready var front_wheels = [get_node("FrontLeftWheel"), get_node("FrontRightWheel")]
@onready var rear_wheels = [get_node("RearLeftWheel"), get_node("RearRightWheel")]

# Car health
@export var car_health: float = 2.0

# Initial position
var initial_position: Transform3D

# Upside-down and position change timers
var upside_down_timer: float = 0.0
var no_position_change_timer: float = 0.0
var previous_position: Vector3

var prev_linear_velocity = Vector3()

func _ready():
	set_car_color(car_color)  # Set the car's color to red
	engine_player.play()
	initial_position = transform
	previous_position = transform.origin
	
	collision_detected.connect(camera._on_collision_detected)

func toggle_breaklights():
	var newMaterial = StandardMaterial3D.new()
	if breaklights_on:
		breaklight_left.light_energy = 1
		breaklight_right.light_energy = 1
		newMaterial.albedo_color = Color(1.8, 0, 0)
	else:
		breaklight_left.light_energy = 0
		breaklight_right.light_energy = 0
		newMaterial.albedo_color = Color(0.2, 0, 0)
	car_mesh.set_surface_override_material(3, newMaterial)

func set_car_color(color: Color):
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = color
	
	# Set car color
	car_mesh.set_surface_override_material(1, newMaterial)

func _physics_process(delta):
	
	# Store the previous linear velocity at the beginning of each physics frame
	prev_linear_velocity = linear_velocity
	
	check_car_reset(delta)

	# Get input values for acceleration, braking, and steering
	var accel_input = get_acceleration_input()
	var steer_input = get_steering_input()

	# Update car state, airborne status, airborne duration, and flip count
	var previous_state = car_state
	update_car_state(accel_input)
	update_airborne_status(delta)
	update_flip_count(delta)
	
	if car_state == previous_state:
		time_in_current_state += delta
	else:
		time_in_current_state = 0
		print_car_state()


	# Handle break lights
	if car_state == CarState.BREAKING or (car_state == CarState.MOVING_REVERSE and accel_input != 0):
		if not breaklights_on:
			breaklights_on = true
			toggle_breaklights()
	else:
		if breaklights_on:
			breaklights_on = false
			toggle_breaklights()

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

func update_airborne_status(delta):
	var wheels_in_contact = 0
	for wheel in front_wheels + rear_wheels:
		if wheel.is_in_contact():
			wheels_in_contact += 1
	var was_airborne = airborne
	airborne = wheels_in_contact == 0
	
	if airborne:
		airborne_timer += delta
	elif was_airborne:
		last_airborne_duration = airborne_timer
		airborne_timer = 0
		print("Airborne duration: %s seconds, Flips: %d" % [last_airborne_duration, flip_count])
		flip_count = 0

func update_flip_count(delta):
	if airborne:
		var current_euler_angles = global_transform.basis.get_euler()
		var rotation_difference = current_euler_angles - previous_euler_angles
		for i in range(3):
			if abs(rotation_difference[i]) > PI:
				rotation_difference[i] = -sign(rotation_difference[i]) * (2 * PI - abs(rotation_difference[i]))
			accumulated_rotation[i] += rotation_difference[i]

			while abs(accumulated_rotation[i]) >= 2 * PI:
				flip_count += 1
				accumulated_rotation[i] -= sign(accumulated_rotation[i]) * 2 * PI

		previous_euler_angles = current_euler_angles
	else:
		previous_euler_angles = Vector3()
		accumulated_rotation = Vector3()


func print_car_state():
	print("Car state changed: ", car_state_labels[car_state])
	
func update_car_state(accel_input: float):
	var speed = linear_velocity.length()
	var forward_speed = linear_velocity.dot(-transform.basis.z)
	
	if speed <= idle_speed_threshold and accel_input == 0:
		car_state = CarState.IDLE
	elif is_car_breaking(accel_input):
		car_state = CarState.BREAKING
	elif forward_speed > idle_speed_threshold:
		car_state = CarState.MOVING_FORWARD
	elif forward_speed < -idle_speed_threshold:
		car_state = CarState.MOVING_REVERSE

func is_car_breaking(accel_input: float) -> bool:
	var forward_speed = linear_velocity.dot(-transform.basis.z)
	var is_reverse_input_pressed = false
	if control_scheme == ControlScheme.ARROWS:
		is_reverse_input_pressed = Input.is_action_pressed("ui_down")
	else:
		is_reverse_input_pressed = Input.is_action_pressed("move_backward")
	return ((accel_input < 0 and forward_speed > 0) or (accel_input > 0 and forward_speed < 0)) and is_reverse_input_pressed

	
func handle_breaklights(accel_input: float):
	var decelerating = (linear_velocity.length() > 0) and ((linear_velocity.normalized().dot(-transform.basis.z) * accel_input) > 0)

	if decelerating:
		if not breaklights_on:
			breaklights_on = true
			toggle_breaklights()
	else:
		if breaklights_on:
			breaklights_on = false
			toggle_breaklights()


func check_car_reset(delta):
	if transform.basis.y.y < 0:
		upside_down_timer += delta
	else:
		upside_down_timer = 0

	if (transform.origin - previous_position).length() < 0.01:
		no_position_change_timer += delta
	else:
		no_position_change_timer = 0

	if (upside_down_timer > 1.0 and no_position_change_timer > 1.0) or transform.origin.y < -10:
		reset_car()

	previous_position = transform.origin


func reset_car():
	transform = initial_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	if car_health <= 0:
		repair_car()

func get_car_state(accel_input: float) -> CarState:
	if accel_input > 0:
		return CarState.MOVING_FORWARD
	elif accel_input < 0:
		return CarState.MOVING_REVERSE
	else:
		return CarState.BREAKING

func add_damage(amount: float):
	car_health = clamp(car_health - amount, 0, 2)
	update_car_mesh()

func repair_car(amount: float = 2.0):
	car_health = clamp(car_health + amount, 0, 2)
	update_car_mesh()

func update_car_mesh():
	if car_health <= 1:
		pass
#		car_mesh.mesh = preload("res://path/to/damaged_car_mesh.tres")
	else:
		pass
#		car_mesh.mesh = preload("res://path/to/regular_car_mesh.tres")

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


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	# Detect high-speed collisions and print
	var collision_speed = linear_velocity.length()
	print("Collision at %s km/h" % (collision_speed * 3.6))
	if collision_speed > 9:
		# Fire one-shot CPUParticles3D
		hit_particles.emitting = true
		
		print("Emitting signal")
		emit_signal("collision_detected")

#
#func _on_body_entered(body):
#	# Detect high-speed collisions and print
#	var collision_speed = linear_velocity.length()
#	print("Collision at %s km/h" % (collision_speed * 3.6))
