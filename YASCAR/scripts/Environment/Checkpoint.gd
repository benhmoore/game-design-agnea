extends Node3D

signal checkpoint_passed
signal finish_passed

var pass_history:Array[VehicleBody3D]

var time = 0.0;
@onready var claim_statuses = [$ClaimStatusP1, $ClaimStatusP2]
@onready var claim_status_p0_init_pos = claim_statuses[0].transform.origin
@onready var claim_status_p1_init_pos = claim_statuses[1].transform.origin

@onready var checkpoint_controller = get_parent()
@onready var highlight_particles = [$HighlightParticlesP1, $HighlightParticlesP2]
var claimed_highlight_particles = [0, 0]

# Determines what texture to show on flag
@export var is_finish = false 
@export var order:int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Cycle checkpoint highlights
	for highlight_particle in highlight_particles:
		highlight_particle.emitting = true
		highlight_particle.emitting = false
	
	checkpoint_controller.connect("checkpoint_highlighted", _on_highlight)
	
	assert(order != -1, """ERROR: You must provide an order for all checkpoints. 
	Select the checkpoint, then enter the checkpoint's order in the inspector, starting with 1. The finish should be the final checkpoint.""");
	
	if is_finish:
		$Finish.visible = true
		$Checkpoint.visible = false
	else:
		$Finish.visible = false
		$Checkpoint.visible = true

func update_color(claim:Node3D, car:VehicleBody3D):
	claim.set_color(car.car_color)
	claim.visible = true
	
func update_highlight_color(highlight_particles: CPUParticles3D, car: Node):
	
	print("Updating highlight color for car!", car)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = car.car_color
	mat.rim_enabled = true
	mat.emission_enabled = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	highlight_particles.mesh.surface_set_material(0, mat)
	
func update_claims():
	for i in range(0, len(pass_history)):
		update_color(claim_statuses[i], pass_history[i])

func _on_highlight(params):
	
	var highlighted_order = params[0]
	var car = params[1]
	
	var index = checkpoint_controller.cars.find(car)
	
	if index == -1: # Car is new to system: find particle system for it
		for i in range(0, len(claimed_highlight_particles)):
			if claimed_highlight_particles[i] == 0:
				index = i
				claimed_highlight_particles[i] = 1
				
				update_highlight_color(highlight_particles[i], car)
				
				break
	
	if order == highlighted_order:
		highlight_particles[index].emitting = true
	else:
		highlight_particles[index].emitting = false

func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	
	if body.is_in_group("Vehicle"):
		if body not in pass_history:
			pass_history.append(body)
			
			body.checkpoints_cleared += 1
			print("Car has passed ", body.checkpoints_cleared, " checkpoints this lap!")
			
			if is_finish:
				emit_signal("finish_passed")
			else:
				emit_signal("checkpoint_passed", [self, body])
		else:
			print("This car is already logged!")

	update_claims()
		
