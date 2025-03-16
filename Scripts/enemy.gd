extends CharacterBody3D

@export var speed : int = 20
@export var distance_to_kill = 10

@onready var my_pitch = randf_range(0.8, 1.1)

var health = 3

signal kill_player


func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 6
	elif velocity == Vector3.ZERO:
		velocity.y = 20
	
	# move to middle
	var direction := global_position.normalized()*-1

	# turn toward the middle
	rotation.y = atan2(direction.x, direction.z)
	
	velocity.x = expDecay(velocity.x, direction.x*speed, 12, delta)
	velocity.z = expDecay(velocity.z, direction.z*speed, 12, delta)
	move_and_slide()
	
	if (global_position.distance_to(Vector3.ZERO) < distance_to_kill):
		emit_signal("kill_player")



func die():
	call_deferred("queue_free")
	# return randi_range(0, 5)

func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)

func damage(bullet_direction : Vector3):
	velocity += bullet_direction*100
	health -= 1
	if (health < 0): die()
