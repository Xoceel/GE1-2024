extends Node

var playback # Will hold the AudioStreamGeneratorPlayback.
var pulse_hz = 440.0 # The frequency of the sound wave - A4
@onready var sample_hz = 22050.0
const YAMAHA_TG_55_PIANO_C_3 = preload("res://Yamaha-TG-55-Piano-C3.wav")
const Sample_440 = preload("res://440.wav")
var current_step = 0
var playing = true

@onready var audio_stream_player_1 = $AudioStreamPlayer
@onready var audio_stream_player_2 = $AudioStreamPlayer2
@onready var audio_stream_player_3 = $AudioStreamPlayer3
@onready var audio_stream_player_4 = $AudioStreamPlayer4
@onready var audio_stream_player_5 = $AudioStreamPlayer5
@onready var audio_stream_player_6 = $AudioStreamPlayer6
@onready var audio_stream_player_7 = $AudioStreamPlayer7
@onready var audio_stream_player_8 = $AudioStreamPlayer8
@onready var audio_stream_player_9 = $AudioStreamPlayer9
@onready var audio_stream_player_10 = $AudioStreamPlayer10
@onready var audio_stream_player_11 = $Player

@onready var audio_stream_players = []

# list of notes that need to be given audio stream generators in the synch player
var notes = []
var step_notes = []
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
	set_audio_streams_sample(YAMAHA_TG_55_PIANO_C_3)
	audio_stream_players = [audio_stream_player_1, audio_stream_player_2, audio_stream_player_3, audio_stream_player_4, audio_stream_player_5, audio_stream_player_6, audio_stream_player_7, audio_stream_player_8, audio_stream_player_9, audio_stream_player_10, audio_stream_player_11]
	show_step(current_step)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("A"):
		notes.append('A')
		play_note(not_playing_audio_player(), 'D')
	if Input.is_action_just_pressed("A#"):
		notes.append('A#')
		play_note(not_playing_audio_player(), 'A')
	if Input.is_action_just_pressed("B"):
		notes.append('B')
	if Input.is_action_just_pressed("C"):
		notes.append('C')
	if Input.is_action_just_pressed("C#"):
		notes.append('C#')
	if Input.is_action_just_pressed("D"):
		notes.append('D')
	if Input.is_action_just_pressed("D#"):
		notes.append('D#')
	if Input.is_action_just_pressed("E"):
		notes.append('E')
	if Input.is_action_just_pressed("F"):
		notes.append('F')
	if Input.is_action_just_pressed("F#"):
		notes.append('F#')
	if Input.is_action_just_pressed("G"):
		notes.append('G')
	if Input.is_action_just_pressed("G#"):
		notes.append('G#')
	if Input.is_action_just_pressed("oct_up"):
		change_octave(2)
	if Input.is_action_just_pressed("oct_down"):
		change_octave(.5)
	if Input.is_action_just_pressed("next_step"):
		show_step(current_step)
		store_step()
		current_step += 1
	if Input.is_action_just_pressed("play_pause"):
		if !playing:
			playing = true
		elif playing:
			playing = false



func clear_notes():
	notes = []

func not_playing_audio_player():
	for i in range(audio_stream_players.size()):
		if not audio_stream_players[i].is_playing():
			print(audio_stream_players[i])
			return audio_stream_players[i]

func change_octave(dir_val):
	for ratio in frequency_ratios:
		frequency_ratios[ratio] *= dir_val

#
func set_audio_streams_sample(stream):
	for i in range(audio_stream_players.size()):
		audio_stream_players[i].stream = stream


func show_step(current_step):
	current_step = current_step % 17
	print("Step: " + str(current_step + 1) + " notes: " + str(notes))

func store_step():
	step_notes.append(notes)
	clear_notes()

func play_note(player, note):
	if player:
		player.pitch_scale = 1
		player.pitch_scale *= frequency_ratios[notes[0]]
		notes.append(note)
		player.play()

func play_notes(current_step):
	if step_notes.size() > current_step:
		for i in range(step_notes[current_step].size()):
			var asp = not_playing_audio_player()
			if asp:
				play_note(asp, i)

func _on_timer_timeout():
	if playing:
		play_notes(current_step)
