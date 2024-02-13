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
signal hit

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
var jump_tween: Tween
var hit_tween: Tween
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

# Handle deselect mouse click
func _input(event):
	if !event is InputEventMouseButton || event.button_mask == 0:
		return
	if selection_disabled || !is_selected:
		return
	
	camera_unsnap_started_ms = Time.get_ticks_msec()
	unsnapping.emit()

func _handle_select():
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

# Handle being hit by arrows
func _on_body_entered(body):
	if !body is Arrow || body.get_node("../../..") is Clover || body.freeze:
		return
	
	if body.get_parent() != $Body/Projectiles:
		body.reparent($Body/Projectiles, true)
		
	body.despawn_disabled = true
	_handle_select()
	hit.emit()

func _jump():
	if Time.get_ticks_msec() < next_jump_ms || \
		(jump_tween != null && jump_tween.is_running()):
			return
	
	next_jump_ms = Time.get_ticks_msec() + randf_range(
		jump_interval_ms.x, jump_interval_ms.y
	)
	
	var init_position = $Body.position
	var jump_duration = randf_range(jump_duration_s.x, jump_duration_s.y)
	
	jump_tween = get_tree().create_tween()
	jump_tween.tween_property(
		$Body,
		"position:y",
		init_position.y + randf_range(jump_height.x, jump_height.y),
		jump_duration / 2
	).set_trans(Tween.TRANS_QUAD)
	
	jump_tween.tween_property(
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

func _spin():
	if (hit_tween != null && hit_tween.is_running()):
		return
	
	# Billboard clover
	$Body.rotation = camera.rotation
	$Body.rotation.x = 0.0
	$Body.rotation.z = 0.0
	
	# Disable material Y-billboard
	var material := $Body.get_active_material(0) as StandardMaterial3D
	material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	
	# Schedule jump
	next_jump_ms = Time.get_ticks_msec()
	
	# Hit tween
	hit_tween = get_tree().create_tween()
	hit_tween.set_parallel(true)
	
	var flip_rotation = randi_range(0, 1) == 1
	var body_rotation = PI * 4
	if flip_rotation:
		body_rotation = -body_rotation
	body_rotation = camera.rotation.y + body_rotation
	
	hit_tween.tween_property(
		$Body,
		"rotation:y",
		body_rotation,
		1
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	hit_tween.set_parallel(false)

	hit_tween.tween_callback(func():
		material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	)
