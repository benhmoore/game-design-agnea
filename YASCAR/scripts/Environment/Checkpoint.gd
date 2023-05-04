extends Node3D

signal checkpoint_passed
signal finish_passed

var pass_history:Array[VehicleBody3D]



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
	pass

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


		
