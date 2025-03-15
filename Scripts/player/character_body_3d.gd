extends CharacterBody3D

const SPEED = 6.0
const SPRINT_ADDED_SPD = 6.0
const JUMP_VELOCITY = 20
const EXP_DECAY = 15.0;

@onready var jumpsound = $jumpsound
@onready var anim = $AnimationPlayer
@onready var playerLookingAt = $Camera3D/playerLookingAt

@export var DialogueGUI : ColorRect
@export var prompts : Node2D
@export var camera : Camera3D

var StopMoving : bool = false

var CamRotation : Vector2 = Vector2(0.0,0.0)
var sensitivity = 0.01
var interactive_element_selected : Node3D = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Handle Inputs
func _input(event):
	if (StopMoving): return
	if (event is InputEventMouseMotion):
		CamRotation += event.relative * sensitivity
		CamRotation.y = clamp(CamRotation.y, -1.5, 1.5)
		
		transform.basis = Basis()
		camera.transform.basis = Basis()
		
		# rot player on x
		rotate_object_local(Vector3(0,1,0),-CamRotation.x)
		# rot cam on y
		camera.rotate_object_local(Vector3(1,0,0),-CamRotation.y)
	elif (event.is_action_pressed("interact") and interactive_element_selected):
		if (interactive_element_selected.is_in_group("npc")):
			DialogueGUI.start_dialogue(interactive_element_selected)
			prompts.hide()
			StopMoving = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 6

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !StopMoving:
		velocity.y = JUMP_VELOCITY
		jumpsound.play()

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var sprint : int = SPRINT_ADDED_SPD if Input.is_action_pressed("sprint") else 0
	if !StopMoving and direction:
		velocity.x = expDecay(velocity.x, direction.x * (SPEED + sprint), EXP_DECAY, delta)
		velocity.z = expDecay(velocity.z, direction.z * (SPEED + sprint), EXP_DECAY, delta)
	else:
		velocity.x = expDecay(velocity.x, 0, EXP_DECAY, delta)
		velocity.z = expDecay(velocity.z, 0, EXP_DECAY, delta)
	
	# move and slide
	move_and_slide()

func _process(_delta: float) -> void:
	if (StopMoving): return
	if (playerLookingAt.is_colliding()):
		if (playerLookingAt.get_collider().is_in_group("npc")):
			interactive_element_selected = playerLookingAt.get_collider()
			prompts.show()
		elif (interactive_element_selected != null):
			interactive_element_selected = null
			prompts.hide()
	elif (interactive_element_selected != null):
		prompts.hide()
		interactive_element_selected = null

func freeze(freeze : bool):
	StopMoving = freeze
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if freeze else Input.MOUSE_MODE_CAPTURED)

# i saw a yt video by freya holmer abt this being a better exponential lerp
func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)

func dead():
	position = Vector3.ZERO
