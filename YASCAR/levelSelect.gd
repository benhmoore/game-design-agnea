extends Control

func _on_level_2_pressed():
	_change_scene("res://level2.tscn")

func _on_level_1_pressed():
	_change_scene("res://level1.tscn")

func _on_level_3_pressed():
	_change_scene("res://level3.tscn")

func _on_back_pressed():
	_change_scene("res://menu.tscn")

func _change_scene(path):
	var next_scene = load(path)
	if next_scene != null:
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("Failed to load scene: ", path)
