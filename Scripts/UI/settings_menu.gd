extends ColorRect

signal main_pause_return

@export var pageButtons : Array[TextureButton]
@export var pages : Array[Control]

@onready var buttonSounds : AudioStreamPlayer = $ButtonSounds
@onready var musicslider : HSlider = $AudioOptions/VBoxContainer/musicSlider
@onready var soundslider : HSlider = $AudioOptions/VBoxContainer/soundSlider
@onready var framerate : OptionButton = $GraphicsOptions/VBoxContainer/FrameRateOptions
@onready var fullscreen : CheckBox = $GraphicsOptions/VBoxContainer/Fullscreen
@onready var vsync : CheckBox = $GraphicsOptions/VBoxContainer/Vsync
@onready var antialiasing : OptionButton = $GraphicsOptions/VBoxContainer/OptionAA

func _ready() -> void:
	var i:= 0
	# set up the menu buttons
	for button in pageButtons:
		button.connect("pressed", to_page.bind(i))
		i+=1
	# set the values under AUDIO
	musicslider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(1)))
	soundslider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(2)))
	# set the values under GRAPHICS
	framerate.select(min(2, int(Engine.max_fps/30)-1))

#region MenuButtons
func to_page(num : int):
	buttonSounds.play()
	# clamp the num
	num = clamp(num, 0, pageButtons.size()-1)
	# select the page button
	pageButtons[num].z_index = 0
	pageButtons[num].position.x = -50
	# select the page
	pages[num].show()
	pages[num].set_process(PROCESS_MODE_INHERIT)
	
	# deselect all the NOT page
	for i in range(pageButtons.size()):
		if (i==num): continue
		# deselect the button
		pageButtons[i].z_index = -1
		pageButtons[i].position.x = 0
		# deselect the page
		pages[i].hide()
		pages[i].set_process(PROCESS_MODE_DISABLED)
#endregion



#region audio
func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_sound_slider_value_changed(value: float) -> void:
	buttonSounds.play()
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
#endregion




#region Graphics
# fullscreen
func set_fullscreen(on : bool):
	buttonSounds.play()
	if (on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# fps
func framerate_selected(index: int) -> void:
	buttonSounds.play()
	match(index):
		0:
			Engine.max_fps = 30
			Engine.set_physics_ticks_per_second(60)
		1:
			Engine.max_fps = 60
			Engine.set_physics_ticks_per_second(60)
		2:
			Engine.max_fps = 120
			Engine.set_physics_ticks_per_second(120)

# sloppily coded because jam
func vsync_toggled(toggled_on: bool) -> void:
	buttonSounds.play()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)

func antialiasing_item_selected(index: int) -> void:
	var viewportrid = get_tree().get_root().get_viewport_rid()
	if (index == 0):
		# disable all
		RenderingServer.viewport_set_msaa_3d(viewportrid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		RenderingServer.viewport_set_scaling_3d_scale(viewportrid, 1)
	if (index < 4):
		# disable ssaa
		RenderingServer.viewport_set_scaling_3d_scale(viewportrid, 1)
		# enable msaa
		match(index):
			1:
				RenderingServer.viewport_set_msaa_3d(viewportrid, RenderingServer.VIEWPORT_MSAA_2X)
			2:
				RenderingServer.viewport_set_msaa_3d(viewportrid, RenderingServer.VIEWPORT_MSAA_4X)
			3:
				RenderingServer.viewport_set_msaa_3d(viewportrid, RenderingServer.VIEWPORT_MSAA_8X)
	else:
		# disable msaa
		RenderingServer.viewport_set_msaa_3d(viewportrid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		# enable ssaa
		RenderingServer.viewport_set_scaling_3d_scale(viewportrid, 4)
#endregion


func _on_return_pressed() -> void:
	emit_signal("main_pause_return")
