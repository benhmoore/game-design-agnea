extends RigidBody3D

var car_node: VehicleBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func remove():
	car_node.pickup = null
	
func use(origin):
	transform.origin = origin
	linear_velocity = car_node.linear_velocity * 3
	
	remove()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
