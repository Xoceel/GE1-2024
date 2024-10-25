extends MeshInstance3D

@onready var tank : Node3D = $"../tank"
var to_player
var forward
var theta
var axis
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	to_player = tank.global_position - global_position
	to_player = to_player.normalized()
	forward = global_transform.basis.z
	DebugDraw3D.draw_arrow(global_position, global_position + forward * 5, Color.BROWN, 0.1)
	DebugDraw2D.set_text("enemy_to_player: ", to_player)
	DebugDraw2D.set_text("enemy_forward_vector: ", forward)
	
	theta = acos(to_player.dot(forward))
	axis = to_player.cross(forward)
	DebugDraw2D.set_text("Axis: ", axis)
	DebugDraw2D.set_text("Angle to player: ", rad_to_deg(theta))
	
	rotation = Vector3(0, theta, 0)
	
	
