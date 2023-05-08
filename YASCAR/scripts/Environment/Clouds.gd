extends Node3D

@export var radius: float = 256
@export var min_cloud_size: int = 10
@export var max_cloud_size: int = 20
@export var min_sphere_scale: float = 0.5
@export var max_sphere_scale: float = 1.0
@export var cloud_speed: float = 1.0
@export var min_spheres_per_cloud: int = 3
@export var max_spheres_per_cloud: int = 6

var clouds_generated: bool = false

func _ready():
	pass

func _process(delta):
	if not clouds_generated:
		create_clouds()
		clouds_generated = true
	else:
		move_clouds(delta)

func create_clouds():
	var cloud_mesh = SphereMesh.new()
	cloud_mesh.radius = 1
	cloud_mesh.height = 1
	cloud_mesh.radial_segments = 6
	cloud_mesh.rings = 4

	var cloud_material = StandardMaterial3D.new()
	cloud_material.flags_transparent = true
	cloud_material.albedo_color = Color(0.8, 0.8, 0.8, 0.5)

	for i in range(randi() % (max_cloud_size - min_cloud_size) + min_cloud_size):
		var cloud_node = Node3D.new()
		var cloud_spheres = randi() % (max_spheres_per_cloud - min_spheres_per_cloud) + min_spheres_per_cloud
		for j in range(cloud_spheres):
			var sphere_instance = MeshInstance3D.new()
			sphere_instance.mesh = cloud_mesh
			sphere_instance.material_override = cloud_material
			sphere_instance.scale = Vector3.ONE * randf_range(min_sphere_scale, max_sphere_scale)
			sphere_instance.transform.origin = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))

			cloud_node.add_child(sphere_instance)

		var random_position = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		cloud_node.transform.origin = Vector3(random_position.x, 0, random_position.y) + self.global_transform.origin

		add_child(cloud_node)

func move_clouds(delta):
	for cloud_node in get_children():
		cloud_node.transform.origin.x += cloud_speed * delta
		if cloud_node.transform.origin.x - self.global_transform.origin.x > radius:
			cloud_node.transform.origin.x = self.global_transform.origin.x - radius
