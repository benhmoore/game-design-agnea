extends Node3D

var car_node:VehicleBody3D
enum ControlScheme { ARROWS, WASD }

@onready var bullet_scene:PackedScene = preload("res://components/Pickups/Bullet.tscn")

var ammo:int = 25
var fire_rate:float = 0.15
var time_since_last_fire:float = 0.0

@onready var fire_particles: CPUParticles3D = $CPUParticles3D
@onready var horn_model: Node3D = $HornModel

var recoil_amount:float = 0.3
var recoil_recovery_rate:float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire(delta):
	# Check if the player has enough ammo to fire
	if ammo <= 0:
		return
	
	# Limit fire rate
	if time_since_last_fire < fire_rate:
		return
		
	fire_particles.emitting = true
	
	time_since_last_fire = 0.0
	
	# Decrease ammo
	ammo -= 1
	
	# Number of bullets in a spray
	var num_bullets = 4

	# Angle between bullets in degrees
	var angle_between_bullets = 6

	for i in range(num_bullets):
		# Spawn bullet instance
		var bullet = bullet_scene.instantiate()
		
		# Set bullet position and rotation to match the car's
		bullet.global_transform = car_node.global_transform
		bullet.transform.origin += Vector3(-1.5, 2, 0)

		# Randomize the bullet color
		var new_mat = StandardMaterial3D.new()
		new_mat.albedo_color = Color8(randi() % 256, randi() % 256, randi() % 256)
		bullet.get_node("MeshInstance3D").set_surface_override_material(0, new_mat)
		
		# Calculate the angle for the current bullet
		var bullet_angle = -angle_between_bullets * (num_bullets - 1) / 2 + i * angle_between_bullets

		# Fire in the direction of the car's velocity with a rotation based on the calculated angle
		var rotated_velocity = car_node.linear_velocity.rotated(Vector3.UP, deg_to_rad(bullet_angle))
		bullet.linear_velocity = rotated_velocity.normalized() * 130
		
		# Add bullet instance to the scene
		get_tree().root.add_child(bullet)
	
	# Apply recoil to the HornModel
	var z_direction = horn_model.transform.basis.z.normalized()
	horn_model.transform.origin += z_direction.rotated(Vector3.UP, deg_to_rad(270)) * recoil_amount


func use(origin):
	car_node.gun = self
	
func remove():
	car_node.pickup = null
	car_node.gun = null
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not car_node: return
	
	transform.origin = car_node.transform.origin + Vector3(0, 2, 0)
	look_at(transform.origin + car_node.linear_velocity.normalized(), Vector3.UP)
	rotate(Vector3.UP, PI / 2)
	
	time_since_last_fire += delta
	
	if ammo < 1:
		remove()
	
	# Use pickup items
	if car_node.control_scheme == ControlScheme.ARROWS:
		if Input.get_action_strength("use_item_slash") > 0:
			fire(delta)
	else:
		if Input.get_action_strength("use_item_q") > 0:
			fire(delta)

	# Recover the recoil of the HornModel
	horn_model.transform.origin = horn_model.transform.origin.lerp(Vector3.ZERO, delta * recoil_recovery_rate)
