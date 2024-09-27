extends Node2D

@export var brick_scene:PackedScene
@export var rows = 10
@export var cols = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			var pos = Vector3(col,row, 0)
			brick.position = pos
			add_child(brick)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
