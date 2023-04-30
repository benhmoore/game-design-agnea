extends Node3D

# Shake parameters
@export var max_shake_duration: float = 0.35
@export var max_shake_intensity: float = 0.0
@export var min_shake_duration: float = 0.0
@export var min_shake_intensity: float = 0.0
@export var speed_threshold: float = 10.0
@export var max_speed: float = 30.0

# Camera follow parameters
@export var follow_distance: float = 5.0
@export var follow_height: float = 0.8

var previous_global_pos = Vector3(0,0,0)

var shake_timer: float = 0.0
var initial_offset: Vector3

# Reference to the vehicle
@export var vehicle: VehicleBody3D

@onready var camera:Camera3D = $Camera3D

# SmoothDamp variables
var target_position_velocity: Vector3 = Vector3.ZERO
var smooth_time: float = 3
var rotation_speed: float = 1.0

func _ready():
	initial_offset = get_position()

func _process(delta: float):
	shake_camera(delta)

func _physics_process(delta: float) -> void:
	move_camera_to_vehicle(delta)
	rotate_camera_to_vehicle_velocity(delta)

func shake_camera(delta: float):
	shake_timer += delta

	if shake_timer >= get_shake_duration():
		shake_timer = 0.0

	var shake_offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * get_shake_intensity()
	set_position(global_transform.origin + shake_offset)

func get_shake_intensity() -> float:
	var car_speed = vehicle.linear_velocity.length()
	var intensity_ratio = clamp((car_speed - speed_threshold) / (max_speed - speed_threshold), 0, 1)
	return lerp(min_shake_intensity, max_shake_intensity, intensity_ratio)

func get_shake_duration() -> float:
	var car_speed = vehicle.linear_velocity.length()
	var duration_ratio = clamp((car_speed - speed_threshold) / (max_speed - speed_threshold), 0, 1)
	return lerp(min_shake_duration, max_shake_duration, duration_ratio)

func move_camera_to_vehicle(delta: float) -> void:
	# Get vehicle's global position, ignoring rotation and orientation
	var vehicle_global_pos = vehicle.global_transform.origin
	
	# Move self to the global position of the car
	global_transform.origin = lerp(global_transform.origin, vehicle_global_pos, delta * smooth_time)
	
	previous_global_pos = global_transform.origin

func rotate_camera_to_vehicle_velocity(delta: float) -> void:
	var vehicle_velocity = vehicle.linear_velocity
	var forward_direction = -vehicle.global_transform.basis.z.normalized()
	var velocity_direction = vehicle_velocity.normalized()
	var lerp_factor = clamp((vehicle_velocity.length() - speed_threshold) / (max_speed - speed_threshold), 0, 1)
	var target_direction = forward_direction.lerp(velocity_direction, lerp_factor)
	
	var target_look_at = vehicle.global_transform.origin + target_direction
	look_at(target_look_at, Vector3.UP)
#	rotation_degrees.y = lerp_angle(rotation_degrees.y, (target_look_at - global_transform.origin).angle_to(Vector3.FORWARD), rotation_speed * delta)

func _on_collision_detected():
	shake_timer = 0.0
#	set_position(initial_offset)
