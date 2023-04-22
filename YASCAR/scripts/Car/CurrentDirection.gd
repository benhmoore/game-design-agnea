extends Marker3D

@onready var turning_speed = get_parent().turning_speed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	
	var target_position = get_parent().get_node("TargetDirection").position
	
	position = lerp(position, target_position, delta * turning_speed)
