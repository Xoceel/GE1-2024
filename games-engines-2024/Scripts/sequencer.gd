extends Marker3D

@export var font:Font
@export var path_str = "res://samples"
@export var pad_scene:PackedScene
@export var steps = 12

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
var probability = 0.0
var randomInt : int = 0
var spectrum

# Load in samples into samples[] : AudioStreams
# Make a beatpad for each sample that toggles colour on collision and plays the instrument
# Set up an array to keep track of all the instruments whether they should be played or not on a given step
# Set up 50 asps to play the audio 
func _ready():
	load_samples()
	make_beatpads()
	initialise_step_arrays()
	for i in range(50):
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		players.push_back(asp)
	play_sample(0,1)
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	print(spectrum)


# I want to check the state of the step balls every frame to see if they have changed
# this should update the according instrument step array and swap them to true if any have been toggled
func _process(delta):
	if last_instrument:
		store_steps(last_instrument)

# Loads all sample and file names into respective lists
func load_samples():
	print("loading samples")
	var dir = DirAccess.open(path_str)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		# From https://forum.godotengine.org/t/loading-an-ogg-or-wav-file-from-res-sfx-in-gdscript/28243/2
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			if file_name.ends_with('.wav.import') or file_name.ends_with('.mp3.import'):
				file_name = file_name.left(len(file_name) - len('.import'))
				var stream:AudioStream = load(path_str + "/" + file_name)
				stream.resource_name = file_name
				samples.push_back(stream)
				file_names.push_back(file_name.left(len(file_name) - 4))
			file_name = dir.get_next()

# Make a beatpad for each sample, all in a row with equal space between them in 3D
# and adds them to a list of pads so I can make sure only one is toggled at a time
func make_beatpads():
	var rowSize = steps
	var row = 0
	for instrument in range(samples.size()):
		row = -(instrument / rowSize)
		var pad = pad_scene.instantiate()
		var p = Vector3(s * (instrument % rowSize) * spacer, s * row * (spacer * 1.3), 0)
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
	for i in range(pads.size()):
		var new_instrument = []
		instrument_steps.push_back(new_instrument)
		for step in range(steps):
			instrument_steps[i].push_back(false)

# might work to get back to old toggle state but toggles aren't being saved rn
func find_steps(instrument):
	for i in range(steps):
		print("Instrument: "+str(instrument) + " Step: " + str(i))
		if instrument_steps[instrument][i]:
			step_balls[i].manual_toggle()

# I want to store the current toggle state of the steps for a given instrument
# this should get done between swapping to a new instrument
func store_steps(last_instrument):
	for i in range(steps):
		if last_instrument:
			instrument_steps[last_instrument][i] = step_balls[i].toggle

# Make the visible balls to show the steps for an instrument
func make_steps():
	if !step_balls.is_empty():
		for i in range(step_balls.size()):
			step_balls[i].queue_free()
		step_balls.clear()
	for step in range(steps):
		var step_ball = pad_scene.instantiate()
		var sb_pos = Vector3(s * step * spacer, s * 2 * spacer, 0)
		step_ball.position = sb_pos
		step_ball.rotation = rotation
		step_ball.get_child(3).set_text("Step: " + str(step + 1))
		add_child(step_ball)
		step_balls.push_back(step_ball)

#func toggle_step(step):
	#instrument_steps[last_instrument][step]

# Plays a singular sample given a sample index 
func play_sample(e, i):
	#print("play sample:" + str(i))
	var p:AudioStream = samples[i]
	var asp = players[asp_index]
	asp.stream = p
	asp.play()
	asp_index = (asp_index + 1) % players.size()

# toggles whether or not the pad is true or false and plays it
func toggle_pad(e, instrument):
	if last_instrument != null:
		store_steps(last_instrument)
		pads[last_instrument].manual_toggle()
	make_steps()
	find_steps(instrument)
	print("toggle " + str(instrument))
	play_sample(0, instrument)
	last_instrument = instrument
	print("last instrument: " + str(last_instrument))

# Goes through each instrument on the current column and plays them if they're true
func play_step(step):
	var p = Vector3(s * step * spacer, s * 2 * spacer, 0)
	$timer_ball.position = p
	for instrument in range(instrument_steps.size()):
		if instrument_steps[instrument][step] and probable_cause():
			play_sample(0, randomizer(instrument))

# Plays the steps on every timer time out and increments the step
func _on_timer_timeout() -> void:
	#print("step " + str(step))
	play_step(step)
	step = (step + 1) % steps
	

# Begins the loop of the sequencer purple ball not blue array of balls
func _on_start_stop_area_entered(area: Area3D) -> void:
	if $Timer.is_stopped():
		$Timer.start()
		$timer_ball.position = Vector3(s * step * spacer, s * 2 * spacer, 0)
		$timer_ball.visible = true
	else:
		$Timer.stop()

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
