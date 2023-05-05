extends Node3D

var car_node:VehicleBody3D
var cars:Array

var initial_rot
var activated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	cars = get_tree().get_nodes_in_group("Vehicle")
	
func use(origin):
	for car in cars:
		print(car)
		if car == car_node:
			continue
		
		var camera = car.camera_gimbal.get_node("Camera3D")
		
		initial_rot = camera.rotation
		
		camera.rotate(Vector3.FORWARD, deg_to_rad(180))
		camera.rotate(Vector3.LEFT, deg_to_rad(30))
		
		activated = true
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if activated:
		await get_tree().create_timer(5).timeout
		for car in cars:
			if car == car_node:
				continue
			
			var camera = car.camera_gimbal.get_node("Camera3D")
			
			camera.rotation = initial_rot
			
		queue_free()
