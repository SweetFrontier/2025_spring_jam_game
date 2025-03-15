extends RigidBody3D

@export var speed: float = 40.0
@export var lifetime: float = 5.0  # Bullet disappears after 5 seconds

var direction = Vector3.ZERO

func _ready():
	linear_velocity = direction * speed
	await get_tree().create_timer(lifetime).timeout
	queue_free()  # Delete itself after `lifetime` seconds

func _on_body_entered(body):
	if body.is_in_group("enemies"):  
		body.queue_free()  # Replace with damage logic if needed
	queue_free()  # Destroy bullet on impact
