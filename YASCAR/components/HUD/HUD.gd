extends CanvasLayer

@export var checkpoint_controller: Node3D
var lap_count_left = 1
var lap_count_right = 1
var lap_count_total = 3

# Called when the node enters the scene tree for the first time.
func _ready():	
	$Left_Car/HUD_Text.clear()
	$Right_Car/HUD_Text.clear()
	$Message/HUD_Text.clear()
	$Left_Car/HUD_Text.append_text("Lap: " + str(lap_count_left) + "/" + str(lap_count_total))
	$Right_Car/HUD_Text.append_text("Lap: " + str(lap_count_right) + "/" + str(lap_count_total))
	pass # Replace with function body.

func _on_checkpoint_controller_car_lapped(car):
	print(car.name, " lapped!")
	if (car.name == "Left_Car"):
		lap_count_left += 1
		$Left_Car/HUD_Text.clear()
		$Left_Car/HUD_Text.append_text("Lap: " + str(lap_count_left) + "/" + str(lap_count_total))
	else:
		lap_count_right += 1
		$Right_Car/HUD_Text.clear()
		$Right_Car/HUD_Text.append_text("Lap: " + str(lap_count_right) + "/" + str(lap_count_total))

	pass # Replace with function body.

func send_to_main_menu():
	print("Sending to main menu in 8 seconds!")
	await get_tree().create_timer(8).timeout
	print("Sending to main menu now!")
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_checkpoint_controller_car_won(car):
	if (car.name == "Left_Car"):
		$Message/HUD_Text.append_text("The Left Car Wins!")
	if (car.name == "Right_Car"):
		$Message/HUD_Text.append_text("The Right Car Wins!")
	send_to_main_menu()
