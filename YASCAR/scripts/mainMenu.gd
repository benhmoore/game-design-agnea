extends Control






func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://levelSelect.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Settings.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_controls_pressed():
	get_tree().change_scene_to_file("res://Controls.tscn")
