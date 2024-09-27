extends Camera3D

var speed = 1
var rot_speed = 0.8
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var f = Input.get_axis("move_back", "move_forward")
	position.z += speed * delta * f
	var r = Input.get_axis("turn_left", "turn_right")
	rotate_y(rot_speed * r * delta)
