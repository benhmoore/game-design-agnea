extends Area3D

enum ItemState {PRONE, INVENTORY, ACTIVE}

var pickups:Dictionary = {
	"tire": {
		"scene": preload("res://components/Pickups/MeshScenes/SpareTireModel.tscn"),
		"enabledScene": preload("res://components/Pickups/Tire.tscn")
	},
	"haybale": {
		"scene": preload("res://components/Pickups/MeshScenes/HayBaleModel.tscn"),
		"enabledScene": preload("res://components/Pickups/HayBale.tscn")
	},
	"oil": {
		"scene": preload("res://components/Pickups/MeshScenes/OilSlickModel.tscn"),
		"enabledScene": preload("res://components/Pickups/Oil.tscn")
	},
	"horn": {
		"scene": preload("res://components/Pickups/MeshScenes/HornModel.tscn"),
		"enabledScene": preload("res://components/Pickups/Horn.tscn")
	},
	"speed_boost": {
		"scene": preload("res://components/Pickups/MeshScenes/SpeedBooster.tscn"),
		"enabledScene": preload("res://components/Pickups/SpeedBooster.tscn")
	},
	"balloons": {
		"scene": preload("res://components/Pickups/MeshScenes/Balloons.tscn"),
		"enabledScene": preload("res://components/Pickups/Balloons.tscn")
	},
}

var pickup

@onready var placeholder = $MysteryItem

var time = 0
@onready var init_pos = transform.origin

# Add export variable for the new mesh
@export var inventory_mesh:PackedScene = null

# Keep track of previous position for stealing
var previous_position: Vector3

var state = ItemState.PRONE
var player_node = null
var current_scale = Vector3.ONE
var transition_progress = 0.0
var transition_speed = 10

var pickup_delay = 4.0
var current_pickup_time = 0

@onready var collider = $CollisionShape3D

# Add scales for the collider in the prone and inventory states
var prone_scale = Vector3.ONE
var inventory_scale = Vector3.ONE * 0.5

func set_pickup(item):
	pickup = item
	
	var scene = item.scene.instantiate()
	add_child(scene)
	placeholder.queue_free()

func determine_item(): # Randomly chooses the item's type when picked up

	# Convert the dictionary to an array
	var pickup_names = pickups.values()

	# Pick a random element from the array
	var random_item = pickup_names[randi() % pickup_names.size()]
	
	set_pickup(random_item)
	
func use():
	
	var enabledScene = pickup.enabledScene.instantiate()
	enabledScene.car_node = player_node
	enabledScene.use(transform.origin)
	
	get_tree().root.add_child(enabledScene)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	prone_scale = collider.shape.extents

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
			
	if player_node != null:
		current_pickup_time += delta

func prone_behavior(delta):
	time += delta
	
	# Calculate the vertical offset based on a wave function
	var offset = sin(time * 2 * PI) * 0.5 + 0.5
	
	# Set the position and rotation of the cube in local space
	var pos = Vector3(0, offset * 0.5, 0)
	var rot = Vector3(0, time * 3, 0)
	
	transform.origin = init_pos + pos
	set_rotation(rot)

	# Reset the collider extents to its original size
	collider.shape.extents = prone_scale
	
	collider.shape.set_margin(0.04)

func inventory_behavior(delta):
	time += delta
	
	# Update transition progress
	transition_progress += delta * transition_speed
	transition_progress = clamp(transition_progress, 0, 1)
	
	# Smoothly scale down and rotate the object
	current_scale = Vector3.ONE.lerp(Vector3.ONE * 0.5, transition_progress)
	var rot = Vector3(0, time * 3, 0)
	set_rotation(rot)

	# Set the collider extents to the inventory size
	collider.shape.set_margin(3)
	
	# Swap the mesh if provided
	if inventory_mesh:
		var mesh_instance = get_node("MeshInstance")
		mesh_instance.set_mesh_instance(inventory_mesh.instance())
		
	# Smoothly follow the body it collides with (player node)
	if player_node:
		var target_position = player_node.global_transform.origin + Vector3(0, 2.5, 0)
		transform.origin = init_pos.lerp(target_position, transition_progress)

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	
	if not body.is_in_group("Vehicle"):
		return
	
	if state == ItemState.PRONE:
		determine_item()
		
	if player_node != body:
		
		var should_pickup = false
		
		# Only allow stealing back after a delay
		if player_node != null: # This means that the pickup has been stolen
			if current_pickup_time > pickup_delay:
				should_pickup = true
				player_node.pickup = null # Remove the pickup from the other player
		else:
			should_pickup = true
			
		init_pos = transform.origin

		if should_pickup:
			body.pickup_item(self)
			state = ItemState.INVENTORY
			player_node = body
			
			transition_progress = 0
			current_pickup_time = 0
