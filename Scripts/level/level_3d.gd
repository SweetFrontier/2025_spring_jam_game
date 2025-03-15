extends Node3D

var in_dialogue : bool = false
var freeze_player : bool = false

func dialogue():
	in_dialogue = true
	freeze_player = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func undialogue():
	in_dialogue = false
	freeze_player = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
