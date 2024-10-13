extends Node

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
var notes = []
var frequencies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print(audio_stream_player_2d.stream.get_sync_stream(0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func clear_notes():
	notes = []

func _on_timer_timeout():
	audio_stream_player_2d.play()
	clear_notes()
