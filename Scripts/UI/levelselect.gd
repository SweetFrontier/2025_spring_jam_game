extends Control

signal startgame

@export var numLevels : int = 0
@onready var levelContainer : GridContainer = $levelContainer

const levelButton = preload("res://Scenes/UI/level_button.tscn")

func _ready() -> void:
	for i in range(numLevels):
		var newbutton = levelButton.instantiate()
		newbutton.get_child(0).text = str(i+1)
		levelContainer.add_child(newbutton)
		newbutton.connect("pressed", play.bind(i))

func play(num : int):
	emit_signal("startgame")
