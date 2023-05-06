extends Node3D

@onready var editor_mesh = $MeshInstance3D

@onready var pickup_container_scene = preload("res://components/Pickups/PickupContainer.tscn")

var current_pickup = null
var should_spawn = false

var time_since_pickup = 0.0

func spawn_pickup():
	current_pickup = pickup_container_scene.instantiate()
	current_pickup.global_transform = global_transform
	current_pickup.attached_to = self
	get_parent().call_deferred("add_child", current_pickup)

func _ready():
	
	# Hide editor mesh from play
	editor_mesh.visible = false
	
	spawn_pickup()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var wr = weakref(current_pickup)
	if (!wr.get_ref()):
		should_spawn = true
	elif current_pickup.attached_to != self:
		should_spawn = true
	
	if should_spawn:
		time_since_pickup += delta
		
		if time_since_pickup > 5.0:
			spawn_pickup()
			time_since_pickup = 0.0
			should_spawn = false
		
		
