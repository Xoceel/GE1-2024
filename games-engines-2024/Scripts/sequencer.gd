extends Marker3D

@export var font:Font
@export var path_str = "res://samples"
@export var pad_scene:PackedScene
@export var steps = 8

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

# Goal remake the sequencer so that it has beat pads 1 per sample
# The sequence steps should be visible and when a sample pad is hit
# you should be looking at the steps of that instrument alone


func _ready():
	load_samples()
	make_beatpads()
	initialise_step_arrays()
	for i in range(50):
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		players.push_back(asp)

func _process(delta):
	check_steps()

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
				file_names.push_back(file_name)
			file_name = dir.get_next()

# Make a beatpad for each sample
func make_beatpads():
	for instrument in range(samples.size()):
		var pad = pad_scene.instantiate()
		var p = Vector3(s * instrument * spacer, s * 0 * spacer, 0)
		pad.position = p
		pad.rotation = rotation
		pad.area_entered.connect(toggle_pad.bind(instrument))
		add_child(pad)
		pads.push_back(pad)

# Creates a new bool array for that instruments steps (should be played on step or not)
func initialise_step_arrays():
	for i in range(samples.size()):
		var new_instrument = []
		instrument_steps.push_back(new_instrument)
		for step in range(steps):
			instrument_steps[i].push_back(false)

func check_steps():
	for i in range(step_balls.size()):
		instrument_steps[last_instrument][i] = step_balls[i].toggle

func make_steps():
	if step_balls:
		for i in range(step_balls.size()):
			step_balls[i].queue_free()
	for step in range(steps):
		var step_ball = pad_scene.instantiate()
		var sb_pos = Vector3(s * step * spacer, s * 2 * spacer, 0)
		step_ball.position = sb_pos
		step_ball.rotation = rotation
		add_child(step_ball)
		step_balls.push_back(step_ball)

func toggle_step(step):
	instrument_steps[last_instrument][step]

# Plays a singular sample given a sample index
func play_sample(e, i):
	print("play sample:" + str(i))
	var p:AudioStream = samples[i]
	var asp = players[asp_index]
	asp.stream = p
	asp.play()
	asp_index = (asp_index + 1) % players.size()

# toggles whether or not the pad is true or false and plays it
func toggle_pad(e, instrument):
	make_steps()
	if last_instrument != null:
		pads[last_instrument].manual_toggle()
	print("toggle " + str(instrument))
	play_sample(0, instrument)
	last_instrument = instrument

# Goes through each instrument on the current column and plays them if they're true
func play_step(step):
	var p = Vector3(s * step * spacer, s * 2 * spacer, 0)
	$timer_ball.position = p
	for instrument in range(instrument_steps.size()):
		if instrument_steps[instrument][step]:
			play_sample(instrument, step)

# Plays the steps on every timer time out and increments the step
func _on_timer_timeout() -> void:
	print("step " + str(step))
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
