extends Node3D

var camera: Camera3D
var lock_started_ms: int

var snap_camera_transform: Transform3D:
	get: return global_transform.translated_local(
		Vector3(0, 1.0, 3.0)
	).looking_at(global_position)
var selected: bool:
	get: return get_parent().is_selected

func _ready():
	for child in get_children():
		(child as GeometryInstance3D).transparency = 1.0

func _process(_delta):
	if selected:
		var transition_progress = min((Time.get_ticks_msec() - lock_started_ms) / 5000.0, 1.0)
		camera.global_transform = camera.global_transform.interpolate_with(
			snap_camera_transform, transition_progress
		)

func _on_body_deselected():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "position:y", 1.5, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)
	
	for child in get_children():
		tween.tween_property(child, "transparency", 1.0, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)

func _on_body_selected(_instance):
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
			self, "position:y", 1.75, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)
	
	for child in get_children():
		tween.tween_property(
			child, "transparency", 0.0, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)
	
	lock_started_ms = Time.get_ticks_msec()
	rotation = camera.rotation
	rotation.x = 0.0
	rotation.z = 0.0
