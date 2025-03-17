extends Node3D

var spawnPositions : Array[Vector3]

@export var testDebugIndex : int = -1
@export var player : Node3D
@export var death_screen : AnimationPlayer
@export var pause_screen : Control

@onready var enemy_scene = preload("res://Scenes/enemy.tscn")

var spawn_new = false
var dead = false
var currRate = 10.0

func _ready() -> void:
	for child in get_children():
		spawnPositions.append(child.global_position)

func _process(delta: float) -> void:
	if (spawn_new): spawn()

func start_to_spawn():
	spawn_new = true

func spawn():
	spawn_new = false
	var enemy = enemy_scene.instantiate()
	enemy.connect("kill_player", kill_player)
	if (testDebugIndex < 0):
		enemy.position = spawnPositions[randi_range(0, 4)]
	else: enemy.position = spawnPositions[testDebugIndex]
	get_tree().current_scene.add_child(enemy)
	
	await get_tree().create_timer(randi_range(currRate-2, currRate+2)).timeout
	if (!dead):
		spawn_new = true
		currRate = max(3, currRate-0.5)

func kill_player():
	if (dead): return
	dead = true
	spawn_new = false
	
	# tell everybody else
	player.freeze()
	pause_screen.set_pausability(false)
	death_screen.play("to_death")
