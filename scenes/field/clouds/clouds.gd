extends Node3D

@export var amount := 50
@export var position_range := Vector3(5, 0.5, 5)

func _ready():
	for i in range(amount):
		var cloud = $Cloud.duplicate()
		add_child(cloud)
		cloud.global_position = Vector3(
			randf_range(-position_range.x, position_range.x),
			global_position.y + randf_range(-position_range.y, position_range.y),
			randf_range(-position_range.z, position_range.z),
		)
		cloud.rotation = Vector3(
			randf_range(0, PI),
			randf_range(0, PI),
			randf_range(0, PI)
		)
		cloud.visible = true
	remove_child($Cloud)
