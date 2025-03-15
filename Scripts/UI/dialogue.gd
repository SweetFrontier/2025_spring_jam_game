extends ColorRect

@export var root : Node
@export var player : Node3D

@onready var text : RichTextLabel = $Text
@onready var npc_name : Label = $Name
@onready var triangle : TextureRect = $Triangle

var in_dialogue : bool = false

var currIndex : int = 0
var currList : PackedStringArray
var currDialogueLength : int = 0
var visibleCharFloat : float = 0.0

var capmode : bool = false

func _ready() -> void:
	visible = false

func start_dialogue(npc):
	var dialogueList = npc.get_dialogue()
	# failsafe just in case
	if (visible):
		return
	# tell the player to stop moving
	player.freeze(true)
	visible = true
	
	# reset mode
	capmode = false
	
	# set the name
	npc_name.text = dialogueList[0]
	
	# set my dialogue
	currList = dialogueList
	currIndex = 0
	visibleCharFloat = 0
	currDialogueLength = 0
	next_dialogue()

func end_dialogue():
	visible = false
	player.freeze(false)
	currList = []

func next_dialogue():
	# skip to display all if must
	if (visibleCharFloat < currDialogueLength):
		visibleCharFloat = currDialogueLength
	elif (currList.size() <= currIndex+1): end_dialogue() # end if done
	else:
		# advance dialogue
		currIndex += 1
		# check if code
		while currList[currIndex].begins_with("{"):
			# failsafe if too far
			if (currList.size() <= currIndex+1):
				end_dialogue()
				return
			# check for cap code
			if (currList[currIndex] == '{CAP}'): capmode = true
			elif (currList[currIndex] == '{NRM}'): capmode = false
			currIndex += 1
		
		currDialogueLength = currList[currIndex].length()
		text.visible_characters = 0
		text.text = currList[currIndex]
		visibleCharFloat = 0
		triangle.hide()
		
		if (capmode):
			text.text = currList[currIndex].to_upper()

func _process(delta: float) -> void:
	if (visible):
		if (currList.size() <= currIndex): end_dialogue()
		if (visibleCharFloat < currDialogueLength):
			visibleCharFloat += delta * 50
			text.visible_characters = floor(visibleCharFloat)
		else:
			text.visible_characters = -1
			triangle.show()

func _input(event: InputEvent) -> void:
	if (visible):
		if (event.is_action_pressed("advance_dialogue") and !event.is_echo()):
			next_dialogue()
