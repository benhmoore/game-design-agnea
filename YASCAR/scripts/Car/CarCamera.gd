extends Camera3D

# Shake parameters
var shake_duration: float = 0.35
var shake_intensity: float = 0.02
var shake_timer: float = 0.0
var is_shaking: bool = false
var initial_offset: Vector3

func _ready():
	initial_offset = get_position()

func _process(delta: float):
	if is_shaking:
		shake_camera(delta)

func shake_camera(delta: float):
	shake_timer += delta
	var shake_offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
	set_position(initial_offset + shake_offset)

	if shake_timer >= shake_duration:
		is_shaking = false
		shake_timer = 0.0
		set_position(initial_offset)

func _on_collision_detected():
	is_shaking = true
	shake_timer = 0.0
