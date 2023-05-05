extends Node3D

@export var lap_count:int = 2

var checkpoints:Array[Node3D]
var finish:Node3D

var cars:Array[VehicleBody3D]
var car_lap:Array[int] # Keep track of the cars' current lap

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
		

func _on_checkpoint_passed():
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
		print("CAR WON!!!!")
	else:
		print("Car is on lap:", passing_car.current_lap)
