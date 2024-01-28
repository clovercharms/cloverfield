extends MeshInstance3D

@export var position_range := Vector2(5.0, 5.0)
@export var direction := Vector3(-1.0, 0.0, -1.0).normalized()
@export var speed := 0.1
@export var height := 5.0

func _process(delta):
	global_position += direction * speed * delta
	
	# Move accordingly when outside range
	if global_position.x < -position_range.x || global_position.x > position_range.x:
		global_position.x = -direction.x * (position_range.x + 1)
	if global_position.z < -position_range.y || global_position.z > position_range.y:
		global_position.z = -direction.z * (position_range.y + 1)
	
	global_position.y = height
