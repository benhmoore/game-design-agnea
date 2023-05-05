extends CanvasLayer

@onready var pausemenu = $pausemenu

func _ready():
	pass

func _process(delta):
	pass
	
	if Input.is_action_pressed("ui_cancel"):
		$".".show()
		get_tree().paused = true




func _on_quit_pressed():
	get_tree().quit()


func _on_resume_pressed():
	print("RESIMING")
	$".".hide()
	get_tree().paused = false
