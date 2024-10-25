extends MeshInstance3D

@onready var tank : Node3D = $"../tank"
var to_player
var forward
var theta
var axis
var q2
var q1
var t
# Called when the node enters the scene tree for the first time.
func _ready():
	to_player = tank.global_position - global_position
	to_player = to_player.normalized()
	forward = global_transform.basis.z
	theta = acos(to_player.dot(forward))
	axis = to_player.cross(forward)
	rotation = Vector3(0, theta, 0)
	q2 = Quaternion(-axis,theta)
	q1 = global_basis.get_rotation_quaternion()
	t = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var q: Quaternion
	t = t + delta
	q = q1.slerp(q2, t)
	global_basis = Basis(q)
	
	
	
	
