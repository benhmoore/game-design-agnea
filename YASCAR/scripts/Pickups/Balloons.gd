extends Node3D

var car_node:VehicleBody3D
enum ControlScheme { ARROWS, WASD }

@onready var bullet_scene:PackedScene = preload("res://components/Pickups/Bullet.tscn")

var inventory:int = 5 
var jump_rate:float = 0.5
var time_since_last_jump:float = 0.0

var recoil_amount:float = 0.3
var recoil_recovery_rate:float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func jump(delta):
	# Check if the player has enough inventory to jump
	if inventory <= 0:
		return
	
	# Limit fire rate
	if time_since_last_jump < jump_rate:
		return
	
	time_since_last_jump = 0.0
	
	# Decrease inventory of jumps
	inventory -= 1

	# Add an impulse to the car to throw it into the air
	var launch_dir = Vector3(car_node.linear_velocity.x, car_node.launch_force / 2.8, car_node.linear_velocity.z)
	car_node.apply_central_impulse(launch_dir)
	
func use(origin):
	car_node.balloons = self
	
func remove():
	car_node.pickup = null
	car_node.balloons = null
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not car_node: return
	
	transform.origin = car_node.transform.origin + Vector3(0, 2, 0)
	look_at(transform.origin + car_node.linear_velocity.normalized(), Vector3.UP)
	rotate(Vector3.UP, PI / 2)
	
	time_since_last_jump += delta
	
	if inventory < 1:
		remove()
	
	# Use pickup items
	if car_node.control_scheme == ControlScheme.ARROWS:
		if Input.get_action_strength("use_item_slash") > 0:
			jump(delta)
	else:
		if Input.get_action_strength("use_item_q") > 0:
			jump(delta)
