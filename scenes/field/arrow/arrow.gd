extends RigidBody3D
class_name Arrow

@export var force := 10.0

func launch(direction: Vector3):
	apply_central_impulse(direction * force)

func _on_static_body_3d_body_entered(body):
	freeze = true
	$StaticBody3D.set_deferred("monitoring", false)
	$StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
