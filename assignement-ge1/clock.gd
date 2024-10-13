extends Node
@onready var timer = $Timer
@export var bpm : float = 60.0


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Timer Started")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer.wait_time = 60 / bpm
	if Input.is_action_just_pressed("bpm_up") and not Input.is_action_pressed("shift"):
		bpm += 5
		print(bpm)
	elif Input.is_action_just_pressed("bpm_up") and Input.is_action_pressed("shift"):
		bpm += 1
		print(bpm)
	
	if Input.is_action_just_pressed("bpm_down") and Input.is_action_pressed("shift"):
		bpm -= 1
		print(bpm)
	elif Input.is_action_just_pressed("bpm_down"):
		bpm -= 5
		print(bpm)


func _on_timer_timeout():
	pass
