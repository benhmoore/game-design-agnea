extends Camera3D

# Shake parameters
@export var max_shake_duration: float = 0.35
@export var max_shake_intensity: float = 0.02
@export var min_shake_duration: float = 0.0
@export var min_shake_intensity: float = 0.0
@export var speed_threshold: float = 10.0
@export var max_speed: float = 30.0

var shake_timer: float = 0.0
var initial_offset: Vector3

# Reference to the vehicle
@onready var vehicle: VehicleBody3D = get_parent()

func _ready():
	initial_offset = get_position()

func _process(delta: float):
	shake_camera(delta)

func shake_camera(delta: float):
	shake_timer += delta

	if shake_timer >= get_shake_duration():
		shake_timer = 0.0
	
	var shake_offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * get_shake_intensity()
	set_position(initial_offset + shake_offset)

func get_shake_intensity() -> float:
	var car_speed = vehicle.linear_velocity.length()
	var intensity_ratio = clamp((car_speed - speed_threshold) / (max_speed - speed_threshold), 0, 1)
	return lerp(min_shake_intensity, max_shake_intensity, intensity_ratio)

func get_shake_duration() -> float:
	var car_speed = vehicle.linear_velocity.length()
	var duration_ratio = clamp((car_speed - speed_threshold) / (max_speed - speed_threshold), 0, 1)
	return lerp(min_shake_duration, max_shake_duration, duration_ratio)

func _on_collision_detected():
	shake_timer = 0.0
	set_position(initial_offset)
