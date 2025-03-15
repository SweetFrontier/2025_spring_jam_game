extends ColorRect


@export var musicFader : AnimationPlayer
@export var Fader : AnimationPlayer
@export var TitleAnimator : AnimationPlayer
@export var buttonSound : AudioStreamPlayer

var waiting : bool = false
var deleteData = {}

# checks if anything is focused; for controller users
var unfocused : bool = true
var currentMenu : int = 0
enum menu {
	main=0,
	select=1,
	settings=2
}

func _ready() -> void:
	$SettingsMenu.connect("main_pause_return", _toggle_settings)

# controller inputs
func _input(event: InputEvent) -> void:
	if (unfocused and event is not InputEventMouse):
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			unfocused = false
			match currentMenu:
				menu.main:
					$maintitle/PlayButton.grab_focus()
				menu.select:
					$Levelselect/levelContainer.get_child(0).grab_focus()

func playButtonPressed():
	if !waiting:
		waiting = true
		buttonSound.play()
		Fader.play("FadeOut")
		await Fader.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Levels/level_3d.tscn")

func levelSelectPressed():
	$maintitle.hide()
	$Levelselect.show()
	currentMenu = menu.select
	# unfocus
	unfocused = true
	$FocusDummy.grab_focus()

func returnFromLevelSelect():
	$maintitle.show()
	$Levelselect.hide()
	currentMenu = menu.settings
	# unfocus
	unfocused = true
	$FocusDummy.grab_focus()

func _toggle_settings():
	unfocused = true
	buttonSound.play()
	$maintitle.visible = !$maintitle.visible
	$SettingsMenu.visible = !$maintitle.visible
	if ($SettingsMenu.visible):
		currentMenu = menu.settings
	else: currentMenu = menu.main
	# unfocus
	unfocused = true
	$FocusDummy.grab_focus()
