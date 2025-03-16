extends Node3D

var spawnPositions : Array[Vector3]

@export var testDebugIndex : int = -1

@onready var enemy_scene = preload("res://Scenes/enemy.tscn")

var spawn_new = true

func _ready() -> void:
	for child in get_children():
		spawnPositions.append(child.global_position)

func _process(delta: float) -> void:
	if (spawn_new): spawn()

func spawn():
	spawn_new = false
	var enemy = enemy_scene.instantiate()
	if (testDebugIndex < 0):
		enemy.position = spawnPositions[randi_range(0, 4)]
	else: enemy.position = spawnPositions[testDebugIndex]
	get_tree().current_scene.add_child(enemy)
	print_debug("SPAWNING AT POS: ", enemy.position)
	
	await get_tree().create_timer(randi_range(8, 12)).timeout
	spawn_new = true
