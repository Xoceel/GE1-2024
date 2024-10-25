extends Marker3D

@export var font:Font 
@export var path_str = "res://samples" 
@export var pad_scene:PackedScene
@export var steps = 8

var rows:int
var cols:int
var s = 0.04
var spacer = 1.1
var sequence = []
var file_names = []
var samples:Array
var players:Array
var asp_index = 0
var step:int = 0

func _ready():
	load_samples()
	initialise_sequence(samples.size(), steps)
	make_sequencer()
	for i in range(50):
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		players.push_back(asp)

func load_samples():
	print("loading samples")
	var dir = DirAccess.open(path_str)
	print(dir)
	if dir:
		print(dir.get_next())
		dir.list_dir_begin()
		var file_name = dir.get_next()
		print(file_name)
		# From https://forum.godotengine.org/t/loading-an-ogg-or-wav-file-from-res-sfx-in-gdscript/28243/2
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			if file_name.ends_with('.wav.import') or file_name.ends_with('.mp3.import'):
				file_name = file_name.left(len(file_name) - len('.import'))
				var stream:AudioStream = load(path_str + "/" + file_name)
				#was working in xr ||||
				#stream.resource_name = file_name
				samples.push_back(stream)
				file_names.push_back(file_name)
			file_name = dir.get_next()

func initialise_sequence(rows, cols):
	for i in range(rows):
		var row = []
		for j in range(cols):
			row.append(false)
		sequence.append(row)
	self.rows = rows
	self.cols = cols

func make_sequencer():
	print(steps)
	for col in range(steps):
		for row in range(samples.size()):
			var pad = pad_scene.instantiate()
			var p = Vector3(s * col * spacer, s * row * spacer, 0)
			pad.position = p
			pad.rotation = rotation
			pad.area_entered.connect(toggle.bind(row, col))
			add_child(pad)

func print_sequence():
	for row in range(samples.size() -1, -1, -1):
		var s = ""
		for col in range(steps):
			s += "1" if sequence[row][col] else "0" 
		print(s)

func play_sample(e, i):
	print("play sample:" + str(i))
	var p:AudioStream = samples[i]
	var asp = players[asp_index]
	asp.stream = p
	asp.play()
	asp_index = (asp_index + 1) % players.size()

func toggle(e, row, col):
	print("toggle " + str(row) + " " + str(col))
	sequence[row][col] = ! sequence[row][col]
	play_sample(0, row)
	print_sequence()

func play_step(col):
	var p = Vector3(s * col * spacer, s * -1 * spacer, 0)
	$timer_ball.position = p
	for row in range(rows):
		if sequence[row][col]:
			play_sample(0, row)

func _on_timer_timeout() -> void:
	print("step " + str(step))
	play_step(step)
	step = (step + 1) % steps

func _on_start_stop_area_entered(area: Area3D) -> void:
	if $Timer.is_stopped():
		$Timer.start()
	else:
		$Timer.stop()
