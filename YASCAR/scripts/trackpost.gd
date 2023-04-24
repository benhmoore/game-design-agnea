#Obtained from https://www.youtube.com/watch?v=QnKYSKzhlTQ
#tool
#Set to run as tool in Godot 4
#Multimesh function - incomplete
extends Path3D

var track_width = 8.0
var rail_dist = 1.0
var lower_ground_width = 12.0 
var is_dirty = true #Variable Exporting in Godot 4?


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_update");
	

func _update():
	if !is_dirty: return
	
	var curve_legnth = curve.get_baked_length()
	
		###################################################################################
	# update our track
	var track_half_width = track_width * 0.5
	var ground_half_width = lower_ground_width * 0.5
	

	var track = $Road.polygon
	track.set(0, Vector2(-track_half_width, 0.0))
	track.set(1, Vector2(-track_half_width, -0.1))
	track.set(2, Vector2( track_half_width, -0.1))
	track.set(3, Vector2( track_half_width, 0.0))
	$Road.polygon = track
	
	var ground = $Ground.polygon
	ground.set(1, Vector2( track_half_width + 2.0, -0.1))
	ground.set(0, Vector2(-track_half_width - 2.0, -0.1))
	ground.set(2, Vector2( lower_ground_width, -4.01))
	ground.set(3, Vector2( lower_ground_width + 0.1, -4.1))
	ground.set(4, Vector2(-lower_ground_width - 0.1, -4.1))
	ground.set(5, Vector2(-lower_ground_width, -4.0))
	$Ground.polygon = ground

	
	###################################################################################
	# update our rails
	var rail_position = track_half_width + rail_dist
	
	var rail = $"Lrail".polygon
	rail.set(0, Vector2(rail_position, 0.5))
	rail.set(1, Vector2(rail_position - 0.05, 0.47))
	rail.set(2, Vector2(rail_position - 0.05, 0.43))
	rail.set(3, Vector2(rail_position, 0.4))
	rail.set(4, Vector2(rail_position, 0.55))
	rail.set(5, Vector2(rail_position - 0.05, 0.32))
	rail.set(6, Vector2(rail_position - 0.05, 0.28))
	rail.set(7, Vector2(rail_position, 0.25))
	rail.set(8, Vector2(rail_position + 0.05, 0.25))
	rail.set(9, Vector2(rail_position + 0.05, 0.5))
	$"Lrail".polygon = rail
	
	rail = $"Rrail".polygon
	rail.set(0, Vector2(-rail_position, 0.5))
	rail.set(1, Vector2(-rail_position + 0.05, 0.47))
	rail.set(2, Vector2(-rail_position + 0.05, 0.43))
	rail.set(3, Vector2(-rail_position, 0.4))
	rail.set(4, Vector2(-rail_position, 0.55))
	rail.set(5, Vector2(-rail_position + 0.05, 0.32))
	rail.set(6, Vector2(-rail_position + 0.05, 0.28))
	rail.set(7, Vector2(-rail_position, 0.25))
	rail.set(8, Vector2(-rail_position - 0.05, 0.25))
	rail.set(9, Vector2(-rail_position - 0.05, 0.5))
	$"Rrail".polygon = rail
	
	###################################################################################
	
	var post_count = floor(curve_legnth / rail_dist)
	var real_post_count = curve_legnth / post_count
	
	$Posts.multimesh.instance_count = post_count * 2
	
	for i in range (0, post_count):
		var t = Transform3D()
		var xf = Transform3D()
		var f = i * curve_legnth / post_count
		
		xf.origin = curve.interpolate_baked(f) #Nonexistent function interpolate_baked in case 'Curve3D'
		var lookat = (curve.interpolate_baked(f + 0.1) - xf.origin).normalized()
		
		var up = Vector3(0.0, 1.0, 0.0)
		xf.basis.z = lookat
		xf.basis.x = lookat.cross(up).normalized()
		xf.basis.y = xf.basis.x.cross(lookat).normalized()
		
		var v = Vector3(track_width * 0.5 + rail_dist, 0.0, 0.0)
		
		t.basis = Basis()
		t.origin = xf.xform(-v)
		$Posts.multimesh.set_instance_transformed(i, t)
		
		t.basis = Basis()
		t.origin = xf.xform(v)
		$Posts.multimesh.set_instance_transformed(post_count + i, t)
	
	
	is_dirty = false

func set_track_width(new_width):
	if track_width != new_width:
		track_width = new_width
		is_dirty = true
		call_deferred("_update")
		
func get_track_width():
	return track_width
	
func set_rail_dist(new_dist):
	if rail_dist != new_dist:
		rail_dist = new_dist
		is_dirty = true
		call_deferred("_update")

func get_rail_dist():
	return rail_dist

func on_path_curve_changed():
	is_dirty = true
	call_deferred("_update")
	
func set_ground_width(new_width):
	if lower_ground_width != new_width:
		lower_ground_width = new_width
		is_dirty = true
		call_deferred("_update")
		
func get_ground_width():
	return lower_ground_width


func _on_curve_changed():
	is_dirty = true
	call_deferred("_update")
