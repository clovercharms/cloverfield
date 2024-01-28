extends Node3D

var camera: Camera3D

func _process(_delta):
	rotation = camera.rotation
	rotation.x = 0
	rotation.z = 0

func _on_body_hover_entered():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", 0.9, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)

func _on_body_hover_exited():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", 0.8, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)

func _on_body_selected(_instance):
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	for child in get_children():
		tween.tween_property(child, "transparency", 1.0, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)

func _on_body_deselected():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	for child in get_children():
		tween.tween_property(child, "transparency", 0.0, 0.25
		).set_ease(Tween.EASE_IN_OUT
		).set_trans(Tween.TRANS_QUAD)
