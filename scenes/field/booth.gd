extends MeshInstance3D

var activated := false

func _ready():
	var animation_player := $Reaper/AnimationPlayer as AnimationPlayer
	animation_player.play(animation_player.get_animation_list()[0])

func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if !event is InputEventMouseButton || \
		event.button_index != 1 || !event.pressed || activated:
			return
	
	activated = true
	$SFX/Roar1.play()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		$Reaper,
		"position:z",
		-3.5,
		5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		$Reaper,
		"rotation:z",
		PI * 8,
		5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
