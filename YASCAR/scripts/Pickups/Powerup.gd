extends Node3D

var car_node: VehicleBody3D

var activated = false
var original_acceleration_force
var original_max_speed
var original_max_fov

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func remove():
	car_node.pickup = null
	queue_free()
	
func use(origin):
	
	
	
	# Store the current acceleration force and max speed of the car_node
	original_acceleration_force = car_node.acceleration_force
	original_max_speed = car_node.max_speed
	original_max_fov = car_node.max_fov

	# Set the acceleration force and max speed to the desired values for 5 seconds
	car_node.acceleration_force = 400.0
	car_node.acceleration_locked = true
	car_node.max_speed = 100.0
	car_node.max_fov = 100.0
	
	activated = true
#
#	# Restore the original acceleration force and max speed
#	car_node.acceleration_force = original_acceleration_force
#	car_node.max_speed = original_max_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	if activated:
		await get_tree().create_timer(5).timeout
		car_node.acceleration_force = original_acceleration_force
		car_node.max_speed = original_max_speed
		car_node.max_fov = original_max_fov
		car_node.acceleration_locked = false
		
		print("Car's nax speed reset", car_node.max_speed)
		
		remove()
		
