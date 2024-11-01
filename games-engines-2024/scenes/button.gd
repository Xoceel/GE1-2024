extends StaticBody3D

signal pressed()

@export var out_color:Color
@export var in_color:Color
@onready var label_3d = $Label3D
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var start_value: float = 0.0
@onready var back_collider = $Area3D/back_collider
@export var textSize:int = 32
@onready var button = $Button

var colliding_with: Area3D
var still_colliding: bool = false

func _ready() -> void:
	print(str(rotation) + " This is the rotation")
	label_3d.set_text(name)
	label_3d.set_font_size(textSize)

func _on_area_3d_area_entered(area: Area3D):
	set_mat(false)
	pressed.emit()
	button.position.y -= .003

func _on_area_3d_area_exited(_area):
	set_mat(true)
	button.position.y += .003

func set_mat(tf):
	if tf:
		button.get_surface_override_material(0).albedo_color = Color(1, 0, 0.216)
	else: button.get_surface_override_material(0).albedo_color = Color(0.431, 0.953, 0)
