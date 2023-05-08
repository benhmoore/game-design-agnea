extends CanvasLayer

@export var checkpoint_controller: Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	checkpoint_controller.connect("car_won", _on_car_won)
	
	pass # Replace with function body.

func _on_car_won(car):
	
	print(car.name, " WON!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
