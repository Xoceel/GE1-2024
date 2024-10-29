extends Area3D

@export var out_color:Color
@export var in_color:Color

var toggle:bool = false
var mat:StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialises a new material and gives it to the pad
	# Changing the color to base color and making it transparent
	mat = StandardMaterial3D.new()
	$MeshInstance3D.set_surface_override_material(0, mat)
	mat.albedo_color = out_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func set_mat():
	# If toggled uses in_color if not toggled uses out_color
	if toggle:
		mat.albedo_color = in_color
	else:
		mat.albedo_color = out_color

func manual_toggle():
	toggle = !toggle
	set_mat()

func _on_area_entered(area: Area3D) -> void:
	#flip toggle
	toggle = !toggle
	#change material
	set_mat()
