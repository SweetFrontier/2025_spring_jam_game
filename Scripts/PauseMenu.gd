extends Control

@onready var sound : AudioStreamPlayer = $ButtonSound
@onready var focusDummy : Control = $focusDummy

@export var musicPlayer : AudioStreamPlayer
@export var Fader : AnimationPlayer
@export var mainPauseMenu : Control
@export var settingsMenu : Control
@export var settingsDisplay : Control

var pauseReload = 0.1 # only pause after 0.1 seconds because i made esc and ` both pause
var pausable : bool = false
var unfocused : bool = true # checks if anything is focused; for controller users
var currentMenu : int = 0
var prevMouseMode : int = 0
enum menu {
	pause=0,
	settings=1
}

func _ready():
	pausable = true
	# connect the settings menu
	settingsMenu.connect("main_pause_return", return_to_main_pause_menu)
	# wait for opening transition to finish before allowing pausing
	if (Fader):
		await Fader.animation_finished
	pausable = true
	# make sure pause menu isnt visible
	visible = false

func _process(delta: float) -> void:
	if pauseReload > 0:
		pauseReload -= delta

#region pause functionality
func _input(event: InputEvent) -> void:
	if (event is not InputEventMouse):
		if !event.is_echo():
			if event.is_action_pressed("pause") and pauseReload < 0:
				if event.pressed:
					togglePause()
					pauseReload = 0.1
		if (unfocused):
			if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
				unfocused = false

func togglePause():
	# dont pause if can't
	if (!pausable && !get_tree().paused): return
	# toggle pause
	sound.play()
	visible = !visible
	get_tree().paused = !get_tree().paused
	
	## IF 3D AND MOUSE CAPTURED
	if (get_tree().paused):
		# pausing, save prior mouse mode and set it to visible
		prevMouseMode = Input.mouse_mode
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		# unpausing, restore original mouse mode
		Input.set_mouse_mode(prevMouseMode)
		# grab the focus dummy
		focusDummy.grab_focus()
		# silently return to main pause menu
		return_to_main_pause_menu(true)

func set_pausability(pause : bool):
	pausable = pause
	if (!pausable and get_tree().paused): togglePause()
#endregion

#region navigation
func _on_settings_pressed() -> void:
	sound.play()
	settingsMenu.show()
	settingsDisplay.show()
	mainPauseMenu.hide()

func return_to_main_pause_menu(silent : bool = false) -> void:
	if (!silent): sound.play()
	mainPauseMenu.show()
	settingsMenu.hide()
	settingsDisplay.hide()

func _on_quit_button_pressed():
	sound.play()
	#musicPlayer.fadeOut()
	Fader.play("FadeOut")
	await(Fader.animation_finished)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")
#endregion
