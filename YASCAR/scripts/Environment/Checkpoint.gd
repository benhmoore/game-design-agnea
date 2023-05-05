extends Node3D

signal checkpoint_passed
signal finish_passed

var pass_history:Array[VehicleBody3D]

var time = 0.0;
@onready var claim_statuses = [$ClaimStatusP1, $ClaimStatusP2]
@onready var claim_status_p0_init_pos = claim_statuses[0].transform.origin
@onready var claim_status_p1_init_pos = claim_statuses[1].transform.origin

# Determines what texture to show on flag
@export var is_finish = false 

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_finish:
		$Finish.visible = true
		$Checkpoint.visible = false
	else:
		$Finish.visible = false
		$Checkpoint.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	# Calculate the vertical offset based on a wave function
	var offset = sin(time * 2 * PI) * 0.5 + 0.5
	
	# Set the position and rotation of the cube in local space
	var pos = Vector3(0, offset * 0.5, 0)
	var rot = Vector3(0, time * 3, 0)
	
	claim_statuses[0].transform.origin = claim_status_p0_init_pos + pos
	claim_statuses[0].set_rotation(rot)
	
	claim_statuses[1].transform.origin = claim_status_p1_init_pos + pos
	claim_statuses[1].set_rotation(rot)


func update_color(claim:MeshInstance3D, car:VehicleBody3D):
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = car.car_color
	
	claim.material_override = newMaterial
	claim.visible = true

func update_claims():
	for i in range(0, len(pass_history)):
		update_color(claim_statuses[i], pass_history[i])

func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	
	if body.is_in_group("Vehicle"):
		print("Car detected!")
		if body not in pass_history:
			pass_history.append(body)
			if is_finish:
				emit_signal("finish_passed")
			else:
				emit_signal("checkpoint_passed")
		else:
			print("This car is already logged!")

	update_claims()
		
