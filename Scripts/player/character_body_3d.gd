extends CharacterBody3D

const SPEED = 20.0
const SPRINT_ADDED_SPD = 12.0
const JUMP_VELOCITY = 20
const EXP_DECAY = 15.0;

@export var bullet_scene: PackedScene

@export var initialFireRate: float = 0.2
@export var upgradedFireRate: float = 0.1
@export var spread_amount: float = 6.0  # Degrees of variation
var fireRate: float
var can_shoot = true

@export var MaxEnergy: float = 100
@export var Energy: float = 100
@export var initialPerShotEnergy: float = 1
@export var upgradedPerShotEnergy: float = 0.5
@export var initialPerSecSprintEnergy: float = 5
@export var upgradedPerSecSprintEnergy: float = 2.5
var perShotEnergy: float
var perSecSprintEnergy: float

var applied_upgrades: Dictionary = {}
## TODO:
# add power mechanic where battery goes up within @exported specified radius from origin
# add shoot mechanic (left click) play $shootsound
# power goes down when use sprint or shoot outside of radius from origin

@onready var shootsound = $shootsound
@onready var anim = $AnimationPlayer
@onready var playerLookingAt = $Camera3D/playerLookingAt

@export var DialogueGUI : ColorRect
@export var prompts : Node2D
@export var camera : Camera3D

var StopMoving : bool = false

var CamRotation : Vector2 = Vector2(0.0,0.0)
var sensitivity = 0.0025
var interactive_element_selected : Node3D = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	perShotEnergy = initialPerShotEnergy
	perSecSprintEnergy = initialPerSecSprintEnergy
	fireRate = initialFireRate

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

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var sprint : int = 0
	if Input.is_action_pressed("sprint") and Energy >= perSecSprintEnergy * delta:
		sprint = SPRINT_ADDED_SPD
		Energy -= perSecSprintEnergy * delta
		print("Energy Remaining: ", Energy)
	if !StopMoving and direction:
		velocity.x = expDecay(velocity.x, direction.x * (SPEED + sprint), EXP_DECAY, delta)
		velocity.z = expDecay(velocity.z, direction.z * (SPEED + sprint), EXP_DECAY, delta)
	else:
		velocity.x = expDecay(velocity.x, 0, EXP_DECAY, delta)
		velocity.z = expDecay(velocity.z, 0, EXP_DECAY, delta)
	
	# move and slide
	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and Energy > perShotEnergy and can_shoot:
		Energy -= perShotEnergy
		print("Energy Remaining: ", Energy)
		shoot()
		can_shoot = false
		await get_tree().create_timer(fireRate).timeout
		can_shoot = true
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

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_transform = $Camera3D/Gun/Muzzle.global_transform  # Spawn at muzzle position
		
		# Add a slight variation in angle
		var random_rotation = Basis()
		random_rotation = random_rotation.rotated(Vector3.RIGHT, deg_to_rad(randf_range(-spread_amount, spread_amount)))  # Vertical spread
		random_rotation = random_rotation.rotated(Vector3.UP, deg_to_rad(randf_range(-spread_amount, spread_amount)))  # Horizontal spread
		
		bullet.direction = -($Camera3D/Gun/Muzzle.global_transform.basis * random_rotation).z  # Apply spread
		get_tree().current_scene.add_child(bullet)

# i saw a yt video by freya holmer abt this being a better exponential lerp
func expDecay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)

func upgrade(upgradeType: Upgrade):
	if upgradeType in applied_upgrades:
		print_debug("Upgrade already applied:", upgradeType)
		return  # Prevent reapplying the same upgrade
		
	# Apply effects based on the upgrade
	match upgradeType:
		Upgrade.REDUCESHOTENERGY:
			perShotEnergy = upgradedPerShotEnergy
		Upgrade.REDUCESPRINTENERGY:
			perSecSprintEnergy = upgradedPerSecSprintEnergy
		Upgrade.INCREASEFIRERATE:
			initialFireRate = upgradedFireRate

func dead():
	position = Vector3.ZERO

enum Upgrade {REDUCESHOTENERGY, REDUCESPRINTENERGY, INCREASEFIRERATE}
