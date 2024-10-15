extends Node

var playback # Will hold the AudioStreamGeneratorPlayback.
var pulse_hz = 440.0 # The frequency of the sound wave - A4


@onready var audio_stream_player = $AudioStreamPlayer
@onready var sample_hz = 44100.0
const YAMAHA_TG_55_PIANO_C_3 = preload("res://Yamaha-TG-55-Piano-C3.wav")
const Sample_440 = preload("res://440.wav")
# list of notes that need to be given audio stream generators in the synch player
var notes = []
# frequencies for the 
var frequency_ratios = {
	'A' : 1, 
	'A#' : 1.059, 
	'B' : 1.122, 
	'C' : 1.189, 
	'C#' : 1.26, 
	'D' : 1.335, 
	'D#' : 1.414, 
	'E' : 1.498, 
	'F' : 1.587, 
	'F#' : 1.682, 
	'G' : 1.782, 
	'G#' : 1.888
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# how to set the audio streams up
	audio_stream_player.stream.set_sync_stream(0, Sample_440)
	
	print(audio_stream_player.stream.stream_count)
	audio_stream_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("A"):
		notes.append('A')

func clear_notes():
	notes = []

func mute_all_streams():
	for i in range(audio_stream_player.stream.stream_count):
		audio_stream_player.stream.set_sync_stream_volume(-100)

func set_audio_streams_sample():
	for i in range(notes.size()):
		audio_stream_player.stream.set_sync_stream(i, Sample_440)

func set_audio_streams_notes():
	for i in range(notes.size()):
		audio_stream_player.stream.get_sync_stream(i).stream.pitch_scale *= frequency_ratios[notes[i]]
		audio_stream_player.stream.set_sync_stream_volume(0)

func _on_timer_timeout():
	set_audio_streams_sample()
	set_audio_streams_notes()
	audio_stream_player.play()
	clear_notes()
