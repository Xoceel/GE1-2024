extends MeshInstance3D

@export var speed : float = .01
@export var rot_speed = 180
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.z -= speed + delta
	rotate_y(deg_to_rad(rot_speed) * delta)
	rotate_x(deg_to_rad(rot_speed) * delta)
	rotate_z(deg_to_rad(rot_speed) * delta)
	
