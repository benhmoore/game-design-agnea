extends Marker3D


var init_pos = position


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	
	var input_x = Input.get_axis("ui_left", "ui_right")
	
	position = init_pos + Vector3(0, 0, -input_x)
