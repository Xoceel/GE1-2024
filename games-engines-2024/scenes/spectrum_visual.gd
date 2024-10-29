extends Node3D

@export var bar:PackedScene
const VU_COUNT = 10
const FREQ_MAX = 11050.0
@onready var end = $End

var width
const HEIGHT = .4
const HEIGHT_SCALE = 8.0
const MIN_DB = 0
const ANIMATION_SPEED = 0.1

var spectrum
var min_values = []
var max_values = []
var bars = []

func make_bars():
	var w = width / VU_COUNT
	for i in range(VU_COUNT):
		var newBar = bar.instantiate()
		newBar.position = Vector3(i * w, 0, 0)
		newBar.rotate_y(deg_to_rad(90))
		newBar.rotate_x(deg_to_rad(90))
		
		add_child(newBar)
		bars.append(newBar)

func _draw():
	var w = width / VU_COUNT
	for i in range(VU_COUNT):
		var min_height = min_values[i]
		var max_height = max_values[i]
		var height = lerp(min_height, max_height, ANIMATION_SPEED)
		
		for bar in bars:
			bar.mesh.size.x = height
		#draw_rect(
				#Rect2(w * i, HEIGHT - height, w - 2, height),
				#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6)
		#)
#
		## Draw a reflection of the bars with lower opacity.
		#draw_rect(
				#Rect2(w * i, HEIGHT, w - 2, height),
				#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6) * Color(1, 1, 1, 0.125)
		#)


func _process(_delta):
	_draw()
	var data = []
	var prev_hz = 0
	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		var height = energy * HEIGHT * HEIGHT_SCALE
		data.append(height)
		prev_hz = hz

	for i in range(VU_COUNT):
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)

		if data[i] <= 0.0:
			min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)
#
	## Sound plays back continuously, so the graph needs to be updated every frame.
	#queue_redraw()


func _ready():
	var pos = global_position
	width =  abs(end.global_position.x - global_position.x)
	make_bars()
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)
