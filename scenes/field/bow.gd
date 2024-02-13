extends Node3D
class_name Bow

@onready var orbit_controls: Control = get_node("../../OrbitControls")
@onready var arrow := preload("res://scenes/field/arrow/arrow.tscn")
@onready var projectiles: Node3D = get_node("../../Projectiles")
@onready var camera: Camera3D = get_parent()
@onready var ray_length := 100000.0;
@export var disabled = false

func _input(event):
	if !event is InputEventMouseButton || event.button_mask != 1 || disabled:
		return
	var mouse_position = _raycast_mouse()
	if !mouse_position:
		return
	
	var arrow: RigidBody3D = arrow.instantiate()
	projectiles.add_child(arrow)
	arrow.global_position = global_position
	arrow.look_at_from_position(global_position, mouse_position)
	arrow.launch(global_position.direction_to(mouse_position))

func _raycast_mouse():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * ray_length
	var ray = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))
	if ray.has("position"):
		return ray["position"]
	return null
