extends MeshInstance3D

@onready var tank : Node3D = $"../tank"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var to_player = tank.global_position - global_position
	var forward = global_transform.basis.z
	DebugDraw3D.draw_arrow(global_position, global_position + forward * 5, Color.BROWN, 0.1)
	DebugDraw2D.set_text("enemy_to_player: ", to_player)
	DebugDraw2D.set_text("enemy_forward_vector: ", forward)
	
