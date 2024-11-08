extends Marker3D

@export var font:Font
@export var path_str = "res://samples/"
@export var pad_scene:PackedScene
@export var steps = 12
@onready var timer = $Timer
@onready var timer_ball = $timer_ball
@onready var steps_marker = $Main_panel/Steps_Marker
@onready var beatpad_marker = $Main_panel/Beatpad_Marker
@onready var main_panel = $Main_panel

var wait_time
var instruments:int
var s = 0.04
var spacer = 1.1
var file_names = []
var samples:Array
var players:Array
var asp_index = 0
var step:int = 0
var last_instrument = null
var instrument_steps = []
var pads = []
var step_balls = []
var randomness = 0.0
var probability = 1.0
var randomInt : int = 0
var volume: float
var rev_toggle: bool = false
var phase_toggle: bool = false

# Load in samples into samples[] : AudioStreams
# Make a beatpad for each sample that toggles colour on collision and plays the instrument
# Set up an array to keep track of all the instruments whether they should be played or not on a given step
# Set up 50 asps to play the audio 
func _ready():
	wait_time = timer.wait_time
	#swing(.75)
	load_samples()
	print(file_names)
	make_beatpads()
	make_steps()
	initialise_step_arrays()
	for i in range(100):
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		players.push_back(asp)

# I want to check the state of the step balls every frame to see if they have changed
# this should update the according instrument step array and swap them to true if any have been toggled
func _process(delta):
	store_steps(last_instrument)

# Load samples from all directories inside the samples folder
func load_samples():
	var loc = DirAccess.open(path_str)
	var dir_names = loc.get_directories()
	for i in range(dir_names.size()):
		var dir = DirAccess.open(path_str + dir_names[i])
		var files = dir.get_files()
		for file in range(files.size()):
			if files[file].ends_with('.import'):
				var stream: AudioStream = load(path_str + dir_names[i] + '/' + files[file].trim_suffix('.import'))
				stream.resource_name = files[file]
				file_names.push_back(files[file].trim_suffix('.import'))
				samples.push_back(stream)

# Make a beatpad for each sample, all in a row with equal space between them in 3D
# and adds them to a list of pads so I can make sure only one is toggled at a time
func make_beatpads():
	var margin = 0.004
	var rowSize = steps
	var row = 0
	for instrument in range(samples.size()):
		row = -(instrument / rowSize)
		var pad = pad_scene.instantiate()
		var p = beatpad_marker.position + Vector3((pad.get_child(1).mesh.size.x + margin) * (instrument % rowSize), s * row * (spacer * 1.3), 0)
		pad.position = p
		pad.rotation = rotation
		pad.area_entered.connect(toggle_pad.bind(instrument))
		pad.get_child(3).set_text(file_names[instrument].left(10))
		add_child(pad)
		pads.push_back(pad)

# Creates a new bool array for that instruments steps (should be played on step or not)
# [[false/true...n_steps],[],[]] where the inside brackets represent an instrument and the bool values
# represent whether they should get played or not on a give step
func initialise_step_arrays():
	for i in range(samples.size()):
		var new_instrument = []
		instrument_steps.push_back(new_instrument)
		for step in range(steps):
			instrument_steps[i].push_back(false)

# might work to get back to old toggle state but toggles aren't being saved rn
func find_steps(instrument):
	for i in range(steps):
		if instrument_steps[instrument][i]:
			step_balls[i].manual_toggle()

# I want to store the current toggle state of the steps for a given instrument
# this should get done between swapping to a new instrument
func store_steps(instrument):
	for i in range(steps):
		if last_instrument != null:
			instrument_steps[instrument][i] = step_balls[i].toggle

# Make the visible balls to show the steps for an instrument
func make_steps():
	var margin = .004
	if !step_balls.is_empty():
		for i in range(step_balls.size()):
			step_balls[i].queue_free()
		step_balls.clear()
	for step in range(steps):
		var step_ball = pad_scene.instantiate()
		var sb_pos = steps_marker.position + Vector3((step_ball.get_child(1).mesh.size.x + margin) * step , 0, 0)
		step_ball.position = sb_pos
		step_ball.rotation = rotation
		step_ball.get_child(3).set_text("Step: " + str(step + 1))
		add_child(step_ball)
		step_balls.push_back(step_ball)

#func toggle_step(step):
	#instrument_steps[last_instrument][step]

# Plays a singular sample given a sample index, e can always be 0
func play_sample(e, i):
	var p:AudioStream = samples[i]
	var asp = players[asp_index]
	asp.stream = p
	asp.volume_db = volume
	asp.play()
	asp_index = (asp_index + 1) % players.size()

# toggles whether or not the pad is true or false and plays it
func toggle_pad(e, instrument):
	if last_instrument != null:
		pads[last_instrument].manual_toggle()
	find_steps(instrument)
	play_sample(0, instrument)
	last_instrument = instrument

# Goes through each instrument on the current column and plays them if they're true
func play_step(step):
	var p = Vector3(s * step * spacer, s * 2 * spacer, 0)
	timer_ball.position = p
	print(timer_ball.position)
	print(step_balls[step].position)
	for instrument in range(instrument_steps.size()):
		if instrument_steps[instrument][step] and probable_cause():
			play_sample(0, randomizer(instrument))
			("playing sample: " + str(samples[instrument]))

# Plays the steps on every timer time out and increments the step
func _on_timer_timeout() -> void:
	play_step(step)
	step = (step + 1) % steps


# Begins the loop of the sequencer purple ball not blue array of balls
func _on_start_stop_area_entered(_area: Area3D) -> void:
	if timer.is_stopped():
		timer.start()
		timer_ball.visible = true
	else:
		timer.stop()

func _on_randomness_new_value(probability_to_randomize):
	randomness = probability_to_randomize

func randomizer(instrument):
	if randf_range(0.0, 1.0) <= randomness:
		return randi_range(0, samples.size()-1)
	else: return instrument

func _on_probability_new_value(value):
	probability = value

func probable_cause() -> bool:
	if randf_range(0.0, 1.0) <= probability:
		return true
	else: return false

func _on_volume_new_value(value):
	value = clamp(value, 0, 180)
	#convert to db
	value = remap(value, 0, 180, 0, -60)
	volume = value

func clear_pattern():
	for i in range(instrument_steps.size()):
		for j in range(steps):
			instrument_steps[i][j] = false
#func swing(ratio):
	##effects the time between beats swing is normally longer on first beat and shorter on second
	##try implementhing this using a number to give a ratio from ranging from 1:1 - 3-1
	#var long_beat:float = wait_time * 2 * ratio
	#var short_beat:float = wait_time * 2 - long_beat
	#if timer.wait_time == wait_time:
		#timer.wait_time = long_beat
	#elif timer.wait_time == long_beat:
		#timer.wait_time = short_beat


func _on_bpm_new_value(value):
	var bpm = remap(value, 0, 180, 60, 480)
	timer.wait_time = 60/bpm


func _on_clear_pattern_pressed():
	for i in range(step_balls.size()):
		if step_balls[i].toggle:
			step_balls[i].manual_toggle()
	clear_pattern()


func _on_reverb_pressed():
	rev_toggle =! rev_toggle
	AudioServer.set_bus_effect_enabled(0, 2, rev_toggle)


func _on_phaser_pressed():
	phase_toggle =! phase_toggle
	AudioServer.set_bus_effect_enabled(0, 2, rev_toggle)

func _on_12_pressed():
	main_panel.scale.x = 1.0
	steps = 12
	make_steps()

func _on_16_pressed():
	main_panel.scale.x = 1.5
	steps = 16
	make_steps()
