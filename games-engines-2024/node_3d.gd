extends Node3D

@export var brick_scene:PackedScene
@export var rows = 10
@export var cols = 10

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	for row in range(rows):
		for col in range(cols):
			var my_random_number = rng.randf_range(-0.5, 0.5)
			var brick = brick_scene.instantiate()
			var pos = Vector3((2 * PI)/col + my_random_number,row - my_random_number, (2 * PI)/col)
			brick.position = pos
			add_child(brick)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
