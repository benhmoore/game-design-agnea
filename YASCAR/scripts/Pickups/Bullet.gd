extends RigidBody3D

# Define the range for randomizing the pitch
var min_pitch_scale: float = 1.2
var max_pitch_scale: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_pitch()
	$AudioStreamPlayer.play()
	await get_tree().create_timer(2).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func randomize_pitch():
	# Set a random pitch_scale value within the specified range
	$AudioStreamPlayer.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
