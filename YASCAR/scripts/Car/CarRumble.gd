extends Node3D

# Parameters
@export var amplitude: float = 0.15
@export var frequency: float = 20

# Variables
var time_passed: float = 0.0
var initial_rotation: Vector3

func _ready():
	initial_rotation = rotation_degrees

func _process(delta: float):
	time_passed += delta
	var rotation_offset = Vector3(0, 0, sin(time_passed * frequency) * amplitude)
	rotation_degrees = initial_rotation + rotation_offset
	print(rotation_degrees)
