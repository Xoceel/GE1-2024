extends StaticBody3D

signal new_value(value: float)


@onready var label_3d = $Label3D
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var start_value: float = 0.0
@onready var back_collider = $Area3D/back_collider
@onready var knob = $Knob
@export var textSize:int = 32

var rot
var extent: float
var value: float
var colliding_with: Area3D
var still_colliding: bool = false

func _ready() -> void:
	label_3d.set_text(name)
	label_3d.set_font_size(textSize)

func _process(_delta):
	if still_colliding:
		update_value(colliding_with.global_rotation)


func update_value(rotation_global: Vector3) -> void:
	rot = knob.rotation.y + (rotation_global.z - knob.rotation.y)
	if rot >= 0:
		rot = clamp(rot, 0, deg_to_rad(180))
		knob.rotation.y = rot
	elif rot <= -2.3:
		knob.rotation.y = deg_to_rad(180)
	else: knob.rotation.y = 0
	value = rad_to_deg(knob.rotation.y)
	new_value.emit(value)


func _on_area_3d_area_entered(area: Area3D):
	colliding_with = area
	still_colliding = true

func _on_area_3d_area_exited(_area):
	still_colliding = false
