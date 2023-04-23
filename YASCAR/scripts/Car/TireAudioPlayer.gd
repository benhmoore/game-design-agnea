extends AudioStreamPlayer

@onready var car: VehicleBody3D = get_parent()
@onready var front_right_wheel: VehicleWheel3D = get_parent().get_node("FrontRightWheel")
#var is_playing = false

var tire_roll_loop = preload("res://assets/sounds/tire_roll_loop.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	stream = tire_roll_loop


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if car.linear_velocity.length() > 0.5 and front_right_wheel.is_in_contact():
		
		if !is_playing():
			play()
	else:
		stop()
