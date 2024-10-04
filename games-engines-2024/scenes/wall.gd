extends Node3D

@export var brick_scene:PackedScene
@export var rows = 10
@export var cols = 10
@export var radius = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			var x = cos(col) * radius
			var z = sin(col) * radius
			var pos = Vector3(x, row+0.5, z)
			brick.position = pos
			
			var m = StandardMaterial3D.new()
			var h = ((row * cols) + col) / (float)(rows * cols)
			m.albedo_color = Color.from_hsv(h, 1, 1)
			var mesh:MeshInstance3D = brick.get_node("MeshInstance3D")
			mesh.set_surface_override_material(0, m)
			add_child(brick)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass