extends CharacterBody3D
class_name Clover

# Movement
@export var speed := 1.0
@export var accel := 1.0
@export var wander_range := 5.0

# Jump
@export var jump_interval_ms := Vector2(2000, 3000)
@export var jump_height := Vector2(0.2, 0.4)
@export var jump_duration_s := Vector2(0.8, 1.2)

# Signals
signal selected(instance: CharacterBody3D)
signal deselected
signal unsnapping
signal deselect_started
signal hover_entered
signal hover_exited

# Camera
var camera: Camera3D
var camera_snap_duration_ms := 5000.0
# Snap point based on label transform
var camera_snap_transform: Transform3D:
	get: return $Label.global_transform.translated_local(
		Vector3(1.0, 0.0, 3.5)
	)
var camera_snap_started_ms: int
var camera_unsnap_transform: Transform3D
var camera_unsnap_started_ms: int
var orbit_controls: Control

# Behavior
var next_jump_ms = randf_range(0, jump_interval_ms.y)
var tween: Tween
var destination: Vector3

# Attributes
var avatar: Texture
var body: Texture

# State
var is_selected := false
var selection_disabled := false

func _ready():
	$Label.camera = camera
	$MiniLabel.camera = camera
	
	var material: StandardMaterial3D = $Label/Avatar.mesh.surface_get_material(0).duplicate()
	material.albedo_texture = avatar
	$Label/Avatar.material_override = material
	
	var material2: StandardMaterial3D = $MiniLabel/Avatar.mesh.surface_get_material(0).duplicate()
	material2.albedo_texture = avatar
	$MiniLabel/Avatar.material_override = material2
	
	var material3: StandardMaterial3D = $MiniLabel/Avatar.mesh.surface_get_material(0).duplicate()
	material3.albedo_texture = avatar
	$Label/Background2.material_override = material3
	
	var body_material: StandardMaterial3D = $Body.mesh.surface_get_material(0).duplicate()
	body_material.albedo_texture = body
	$Body.material_override = body_material

func _process(delta):
	_snap_camera()
	
	_wander();
	
	var direction = ($NavigationAgent3D.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()
	
	_jump()
	

func _input(event):
	if !event is InputEventMouseButton || event.button_mask == 0:
		return
	if selection_disabled:
		return
	
	if is_selected:
		camera_unsnap_started_ms = Time.get_ticks_msec()
		unsnapping.emit()

# Handle click event (selecting) the clover
func _on_body_input_event(_camera, event, _position, _normal, _shape_idx):
	# Check mouse button press
	if !event is InputEventMouseButton || \
		event.button_index != 1 || \
		!event.pressed:
			return
	if selection_disabled || is_selected: return
	
	is_selected = !is_selected
	selected.emit(self)
	
	# Y billboard label
	$Label.rotation = camera.rotation
	$Label.rotation.x = 0.0
	$Label.rotation.z = 0.0
	
	# Store previous camera position to unsnap later
	camera_unsnap_transform = camera.transform
	# Start snap
	camera_snap_started_ms = Time.get_ticks_msec()

# Update cursors on hover
func _on_body_mouse_entered():
	if selection_disabled: return
	
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover_entered.emit()

func _on_body_mouse_exited():
	if selection_disabled: return
	
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	hover_exited.emit()

func _jump():
	if Time.get_ticks_msec() < next_jump_ms || \
		(tween != null && tween.is_running()):
			return
	
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

func _wander():
	if destination != Vector3.ZERO && global_position.distance_to(destination) > 0.5:
		return
		
	# Generate random walking position
	destination = Vector3(
		randf_range(-wander_range, wander_range),
		0.5,
		randf_range(-wander_range, wander_range)
	)
	destination = NavigationServer3D.map_get_closest_point(
		NavigationServer3D.get_maps()[0],
		destination
	);
	$NavigationAgent3D.target_position = destination

func _snap_camera():
	var started = 0
	var unsnapping = camera_unsnap_started_ms != 0
	
	# Determine start time
	if is_selected && !unsnapping:
		started = camera_snap_started_ms
	else:
		started = camera_unsnap_started_ms
	if started == 0:
		return
	
	# Calculate snap/unsnap progress
	var transition_progress = min(
		(Time.get_ticks_msec() - started) / camera_snap_duration_ms, 1.0
	)
	
	# Unsnap end
	if camera_unsnap_started_ms != 0 && transition_progress >= 0.1:
		camera_unsnap_started_ms = 0
		is_selected = false
		deselected.emit()
		# FIXME Die
		queue_free()
		return
	
	# Update camera interpolation
	if !unsnapping:
		camera.global_transform = camera.global_transform.interpolate_with(
			camera_snap_transform, transition_progress
		)
	else:
		camera.global_transform = camera.global_transform.interpolate_with(
			camera_unsnap_transform, transition_progress
		)
