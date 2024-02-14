extends RigidBody3D
class_name Arrow

@export var force := 10.0
@export var despawn_disabled := false

func launch(direction: Vector3):
	apply_central_impulse(direction * force)

func _on_static_body_3d_body_entered(body):
	if !freeze:
		$SFX/Hit.play()
	
	freeze = true
	$StaticBody3D.set_deferred("monitoring", false)
	$StaticBody3D/CollisionShape3D.set_deferred("disabled", true)

func _on_despawn_timer_timeout():
	if despawn_disabled:
		return
	queue_free()

func _integrate_forces(state):
	if despawn_disabled:
		return
	
	look_at(global_position + state.linear_velocity)
