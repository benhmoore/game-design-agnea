extends Node3D

var time = 0.0
@onready var init_pos = transform.origin

@onready var mesh:MeshInstance3D = $Checkbox/Cube

func _process(delta):
	time += delta
	
	# Calculate the vertical offset based on a wave function
	var offset = sin(time * 2 * PI) * 0.5 + 0.5
	
	# Set the position and rotation of the cube in local space
	var pos = Vector3(0, offset * 0.5, 0)
	var rot = Vector3(0, time * 3, 0)
	
	transform.origin = init_pos + pos
	set_rotation(rot)


func set_color(color:Color):
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.rim_enabled = true
	mat.emission_enabled = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	mesh.set_surface_override_material(0, mat)
