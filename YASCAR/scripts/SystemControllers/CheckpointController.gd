extends Node3D

signal checkpoint_highlighted
signal car_lapped
signal car_won

@export var lap_count:int = 2

var checkpoints:Array[Node3D]
var finish:Node3D

var cars:Array[VehicleBody3D]

var car_lap:Array[int] # Keep track of the cars' current lap


func compareCheckpoints(a, b):
	return a.order < b.order

# Called when the node enters the scene tree for the first time.
func _ready():
	for checkpoint in get_children():
		
		if checkpoint.get("is_finish") == null: continue
		
		if checkpoint.is_finish == true:
			finish = checkpoint
			checkpoint.connect("finish_passed", _on_finish_passed)
		else:
			checkpoints.append(checkpoint)
			checkpoint.connect("checkpoint_passed", _on_checkpoint_passed)

func update_status():
	
	# Update cars array
	for checkpoint in checkpoints:
		
		# Detect cars based on passage through checkpoints
		for car in checkpoint.pass_history:
			if car not in cars:
				cars.append(car)
				
	for car in cars:
		var can_finish = true
		for checkpoint in checkpoints:
			if car not in checkpoint.pass_history:
				can_finish = false
				
		car.can_finish = can_finish
		if can_finish:
			print("Car can finish!", car)

func reset_checkpoints(car):
	for checkpoint in checkpoints:
		var index = checkpoint.pass_history.find(car)
		checkpoint.pass_history.erase(car)
		
		checkpoint.claim_statuses[index].visible = false
		
	# Highlight first checkpoint
	emit_signal("checkpoint_highlighted", [checkpoints[0].order, car])

func highlight_next_checkpoint(checkpoint):
	
	var passing_car = checkpoint.pass_history[-1]
	checkpoints.sort_custom(compareCheckpoints)	
	for i in range(0, len(checkpoints)):
		if passing_car not in checkpoints[i].pass_history:
			emit_signal("checkpoint_highlighted", [checkpoints[i].order, passing_car])
			break
			
		# Highlight finish
		if i == len(checkpoints) - 1:
			emit_signal("checkpoint_highlighted", [finish.order, passing_car])
			
	

func _on_checkpoint_passed(order):
	print("Checkpoint at the following order passed: ", order)
	highlight_next_checkpoint(order)
	update_status()
	
func _on_finish_passed():
	var passing_car = finish.pass_history[-1] # The most recent car to pass the finish line
	
	if passing_car.can_finish:
		if passing_car.current_lap < lap_count:
			passing_car.current_lap += 1
			
			# If car has lapped, reset checkpoints
			reset_checkpoints(passing_car)
			
			
	finish.pass_history.erase(passing_car)
	
	if passing_car.current_lap == lap_count:
		emit_signal("car_won", passing_car)
	else:
		emit_signal("car_lapped", passing_car)
