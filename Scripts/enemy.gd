extends CharacterBody3D



func _process(delta: float) -> void:
	# turn toward the middle
	rotation.y = acos(global_position.normalized().z)
	if global_position.x > 0: rotation.y *= -1
	
	# move to middle
	var direction := global_position.normalized()
	velocity.x = -direction.x*20
	velocity.z = -direction.z*20
	
	move_and_slide()



func die() -> int:
	return randi_range(0, 5)
	call_deferred("queue_free")

func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)
