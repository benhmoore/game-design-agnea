extends CanvasLayer

@export var checkpoint_controller: Node3D


# Called when the node enters the scene tree for the first time.
func _ready():	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_checkpoint_controller_car_lapped(car):
	print(car.name, " lapped!")
	pass # Replace with function body.


func _on_checkpoint_controller_car_won(car):
	print(car.name, " WON!")
	pass # Replace with function body.
