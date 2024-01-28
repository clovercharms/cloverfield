extends CharacterBody3D

@export var jump_interval_ms = Vector2(2000, 3000)
@export var jump_height = Vector2(0.2, 0.4)
@export var jump_duration_s = Vector2(0.8, 1.2)

@export var speed = 1.0
@export var accel = 1.0

@export var interactivity_range = 6.0

signal selected(instance: CharacterBody3D)
signal deselected
signal hover_entered
signal hover_exited

var camera: Camera3D
var next_jump_ms = randf_range(0, jump_interval_ms.y)
var tween: Tween
var destination: Vector3
var avatar: Texture

var is_selected := false
var selection_disabled := false

# Only allow selecting the clover inside certain range
var inside_interactivity_range: bool:
	get: return global_position.distance_to(
		camera.global_position
	) < interactivity_range

func _ready():
	$Label.camera = camera
	$MiniLabel.camera = camera
	var material: StandardMaterial3D = $Label/Avatar.mesh.surface_get_material(0).duplicate()
	material.albedo_texture = avatar
	$Label/Avatar.material_override = material
	var material2: StandardMaterial3D = $MiniLabel/Avatar.mesh.surface_get_material(0).duplicate()
	material2.albedo_texture = avatar
	$MiniLabel/Avatar.material_override = material2

func _process(delta):
	# Generate random walking position
	if destination == Vector3.ZERO || global_position.distance_to(destination) < 0.5:
		destination = Vector3(
			randf_range(-5, 5),
			0.5,
			randf_range(-5, 5)
		)
		$NavigationAgent3D.target_position = destination
	
	var direction = ($NavigationAgent3D.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()
	
	# Jump randomly
	if Time.get_ticks_msec() >= next_jump_ms && \
		(tween == null || !tween.is_running()):
		_jump()
	

func _input(event):
	if !event is InputEventMouseButton || event.button_mask == 0:
		return
	
	if is_selected && !selection_disabled:
		is_selected = false
		deselected.emit()

# Handle click event (selecting) the clover
func _on_body_input_event(_camera, event, _position, _normal, _shape_idx):
	if !event is InputEventMouseButton || \
		event.button_index != 1 || \
		!event.pressed:
			return
	if !inside_interactivity_range: return
	if selection_disabled: return
	if is_selected: return
	
	is_selected = !is_selected
	selected.emit(self)

# Update cursors on hover
func _on_body_mouse_entered():
	if !inside_interactivity_range: return
	
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover_entered.emit()

func _on_body_mouse_exited():
	if !inside_interactivity_range: return
	
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	hover_exited.emit()

func _jump():
	next_jump_ms = Time.get_ticks_msec() + randf_range(
		jump_interval_ms.x, jump_interval_ms.y
	)
	
	var init_position = $Body.position
	var jump_duration = randf_range(jump_duration_s.x, jump_duration_s.y)
	
	tween = get_tree().create_tween()
	tween.tween_property(
		$Body,
		"position:y",
		init_position.y + randf_range(jump_height.x, jump_height.y),
		jump_duration / 2
	).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(
		$Body,
		"position:y",
		init_position.y,
		jump_duration / 2
	).set_trans(Tween.TRANS_QUAD)
