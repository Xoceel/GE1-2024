extends Node3D

class_name TerrainGenerator

# Configuration
@export_group("Terrain Settings")
@export var quads_per_tile: int = 10
@export var height_scale: float = 10.0
@export var width_scale: float = 100.0
@export var perlin_scale: float = 0.1
@export var speed: float = 1.0
@export var material: Material

@export_group("Height Thresholds")
@export var low: float = 1.0
@export var high: float = 0.0

# Node references
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var current_mesh: ArrayMesh
var noise_generator: FastNoiseLite

# State
var t: float = 0.0
var is_initialized: bool = false

func _enter_tree() -> void:
	# Initialize components that don't depend on the scene tree
	initialize_noise_generator()

func _ready() -> void:
	# Perform scene-dependent initialization
	if not is_initialized:
		generate_terrain()
		is_initialized = true

func initialize_noise_generator() -> void:
	noise_generator = FastNoiseLite.new()
	noise_generator.seed = 1234
	noise_generator.frequency = 1.0

func generate_terrain() -> void:
	setup_mesh_instance()
	setup_collision()
	create_terrain_mesh()
	apply_mesh_and_collision()

func setup_mesh_instance() -> void:
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)

func setup_collision() -> void:
	var static_body = StaticBody3D.new()
	add_child(static_body)
	collision_shape = CollisionShape3D.new()
	static_body.add_child(collision_shape)

func apply_mesh_and_collision() -> void:
	mesh_instance.mesh = current_mesh
	mesh_instance.material_override = material
	
	var collision_shape_mesh = ConcavePolygonShape3D.new()
	collision_shape_mesh.set_faces(current_mesh.get_faces())
	collision_shape.shape = collision_shape_mesh

func create_terrain_mesh() -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var bottom_left = Vector3(-quads_per_tile / 2.0, 0, -quads_per_tile / 2.0)
	
	for row in range(quads_per_tile):
		for col in range(quads_per_tile):
			generate_quad(surface_tool, bottom_left, row, col)
	
	surface_tool.generate_tangents()
	surface_tool.generate_normals()
	current_mesh = surface_tool.commit()

func generate_quad(surface_tool: SurfaceTool, bottom_left: Vector3, row: int, col: int) -> void:
	var vertices = calculate_quad_vertices(bottom_left, row, col)
	var uvs = calculate_quad_uvs(row, col)
	
	generate_triangle(surface_tool, vertices.bl, vertices.br, vertices.tl, uvs.bl, uvs.br, uvs.tl)
	generate_triangle(surface_tool, vertices.br, vertices.tr, vertices.tl, uvs.br, uvs.tr, uvs.tl)

func calculate_quad_vertices(bottom_left: Vector3, row: int, col: int) -> Dictionary:
	return {
		"bl": bottom_left + Vector3(col * width_scale, sample_height(row, col), row * width_scale),
		"tl": bottom_left + Vector3(col * width_scale, sample_height(row + 1, col), (row + 1) * width_scale),
		"tr": bottom_left + Vector3((col + 1) * width_scale, sample_height(row + 1, col + 1), (row + 1) * width_scale),
		"br": bottom_left + Vector3((col + 1) * width_scale, sample_height(row, col + 1), row * width_scale)
	}

func calculate_quad_uvs(row: int, col: int) -> Dictionary:
	return {
		"bl": Vector2(float(col) / quads_per_tile, float(row) / quads_per_tile),
		"tl": Vector2(float(col) / quads_per_tile, float(row + 1) / quads_per_tile),
		"tr": Vector2(float(col + 1) / quads_per_tile, float(row + 1) / quads_per_tile),
		"br": Vector2(float(col + 1) / quads_per_tile, float(row) / quads_per_tile)
	}

func generate_triangle(surface_tool: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, 
					  uv1: Vector2, uv2: Vector2, uv3: Vector2) -> void:
	var normal = (v2 - v1).cross(v3 - v1).normalized()
	
	surface_tool.set_normal(normal)
	surface_tool.set_uv(uv1)
	surface_tool.add_vertex(v1)
	
	surface_tool.set_normal(normal)
	surface_tool.set_uv(uv2)
	surface_tool.add_vertex(v2)
	
	surface_tool.set_normal(normal)
	surface_tool.set_uv(uv3)
	surface_tool.add_vertex(v3)

func sample_height(row: float, col: float) -> float:
	var world_pos = global_position
	var sample_x = ((col * width_scale) + world_pos.x) * perlin_scale
	var sample_z = ((row * width_scale) + world_pos.z) * perlin_scale
	var noise_value = sample_noise(sample_x, sample_z)
	return noise_value * 100

func sample_noise(x: float, z: float) -> float:
	var noise = (noise_generator.get_noise_2d(x, z) + 1.0) / 2.0
	var mid = 0.5
	
	if noise > high:
		return mid + (noise - high)
	elif noise < low:
		return mid + (noise - low)
	
	return mid
