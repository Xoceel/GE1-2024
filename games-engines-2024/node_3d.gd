extends Node3D

@export var brick_scene:PackedScene
@export var rows = 10
@export var cols = 20
@export var radius = 3


var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var radInc = (2 * PI) / cols
	
	rng.randomize()
	for row in range(rows):
		for col in range(cols):
			var angle = col * radInc
			print(angle)
			var brick = brick_scene.instantiate()
			var pos = Vector3(radius * cos(angle), row , radius * sin(angle))
			brick.position = pos
			add_child(brick)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
