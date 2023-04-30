extends Area3D

enum ItemState {PRONE, INVENTORY, ACTIVE}

var time = 0
@onready var init_pos = transform.origin

# Add export variable for the new mesh
@export var inventory_mesh:PackedScene = null

var state = ItemState.PRONE
var player_node = null
var current_scale = Vector3.ONE
var transition_progress = 0.0
var transition_speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale = current_scale
	# Process different states
	match state:
		ItemState.PRONE:
			prone_behavior(delta)
		ItemState.INVENTORY:
			inventory_behavior(delta)
		ItemState.ACTIVE:
			pass

func prone_behavior(delta):
	time += delta
	
	# Calculate the vertical offset based on a wave function
	var offset = sin(time * 2 * PI) * 0.5 + 0.5
	
	# Set the position and rotation of the cube in local space
	var pos = Vector3(0, offset * 0.5, 0)
	var rot = Vector3(0, time * 3, 0)
	
	transform.origin = init_pos + pos
	set_rotation(rot)

func inventory_behavior(delta):
	time += delta
	
	# Update transition progress
	transition_progress += delta * transition_speed
	transition_progress = clamp(transition_progress, 0, 1)
	
	# Smoothly scale down and rotate the object
	current_scale = Vector3.ONE.lerp(Vector3.ONE * 0.5, transition_progress)
	var rot = Vector3(0, time * 3, 0)
	set_rotation(rot)
	
	# Swap the mesh if provided
	if inventory_mesh:
		var mesh_instance = get_node("MeshInstance")
		mesh_instance.set_mesh_instance(inventory_mesh.instance())
		
	# Smoothly follow the body it collides with (player node)
	if player_node:
		var target_position = player_node.global_transform.origin + Vector3(0, 2.5, 0)
		transform.origin = init_pos.lerp(target_position, transition_progress)

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Vehicle"):
		body.pickup_item(self)
		state = ItemState.INVENTORY
		player_node = body
		transition_progress = 0
