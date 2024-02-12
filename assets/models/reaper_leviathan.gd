extends Node3D

func _ready():
	var animation_player := $AnimationPlayer as AnimationPlayer
	animation_player.play(animation_player.get_animation_list()[0])
