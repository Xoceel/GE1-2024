extends MeshInstance3D

@export var speed = 10
@export var rot_speed = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#position.z -= speed + delta
	var f = Input.get_axis("move_back", "move_forward")
	var r = Input.get_axis("turn_right", "turn_left")
	translate(Vector3(0, 0, f * delta * speed))
	rotate_y(rot_speed * r * delta)
	#rotate_y(deg_to_rad(rot_speed) * delta)
	#rotate_x(deg_to_rad(rot_speed) * delta)
	#rotate_z(deg_to_rad(rot_speed) * delta)
	
