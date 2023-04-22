extends Node2D





func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Settings.tscn")


func _on_quit_pressed():
	get_tree().quit()
