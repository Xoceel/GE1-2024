extends MeshInstance3D

var height: float = 0.001
var width: float = 0.4


# Called when the node enters the scene tree for the first time.
func _ready():
	mesh.size.x = width
	mesh.size.y = height


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
