extends StaticBody3D

signal new_value(value: float)



@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var start_value: float = 1.0
@onready var slide = $slide
@onready var back_collider = $Area3D/back_collider

var rot: Vector3
var extent: float
var value: float
var colliding_with: Area3D
var still_colliding: bool = false

func _ready() -> void:
	extent = (back_collider.shape.size.y * 0.5) * 0.8
	slide.position.y = remap(start_value, 0.0, 1.0, -extent, extent)

func _process(delta):
	if still_colliding:
		update_value(colliding_with.global_position)


func update_value(location_global: Vector3) -> void:
	var location_local = to_local(location_global)
	slide.position.y = clamp(location_local.y, -extent, extent)
	value = remap(slide.position.y, -extent, extent, min_value, max_value)

	new_value.emit(value)


func _on_area_3d_area_entered(area: Area3D):
	colliding_with = area
	still_colliding = true

func _on_area_3d_area_exited(area):
	still_colliding = false
