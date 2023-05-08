extends Node3D


@export var car:VehicleBody3D

@onready var audio_stream_player:AudioStreamPlayer = $AudioStreamPlayer 

var soundtrack = preload("res://assets/sounds/car_brake.wav")
var soundtrack1 = preload("res://assets/sounds/car_horn.wav")
var soundtrack2 = preload("res://assets/sounds/item_pickup.wav")
var soundtrack3 = preload("res://assets/sounds/item_in_use.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Car states: car_breaking, car_moving_forward, car_moving_backward, car_idle, car_honking, collision_detected
	car.connect("car_breaking", _on_car_breaking)
	car.connect("car_honking", _the_car_honking)
	car.connect("car_picking_up_item", _pickup_item)
	car.connect("car_using_pickup", _item_in_use)

func _on_car_breaking():
	audio_stream_player.volume_db = -17
	audio_stream_player.stream = soundtrack
	audio_stream_player.play()
	
	
func _the_car_honking():
	audio_stream_player.volume_db = -25
	audio_stream_player.stream = soundtrack1
	audio_stream_player.play()
	
func _pickup_item():
	audio_stream_player.volume_db = -15
	audio_stream_player.stream = soundtrack2
	audio_stream_player.play()

func _item_in_use():
	audio_stream_player.volume_db = -15
	audio_stream_player.stream = soundtrack3
	audio_stream_player.play()
