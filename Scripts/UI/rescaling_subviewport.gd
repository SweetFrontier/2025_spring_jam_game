extends SubViewport

var root_viewport : Viewport
var within_the_viewport : Control

@onready var display : SubViewportContainer = get_parent()

func _ready():
	root_viewport = get_tree().get_root().get_viewport()
	root_viewport.connect("size_changed", _on_root_viewport_size_changed)
	within_the_viewport = get_child(0)
	_on_root_viewport_size_changed()

func _on_root_viewport_size_changed():
	var root_size : Vector2 = root_viewport.size
	
	# lock to 16/9
	root_size.x = floor(min(root_size.x, root_size.y*1.777778))
	root_size.y = floor(min(root_size.x*0.5625, root_size.y))
	# set the rendering scale
	size = root_size
	var percentsize = (root_size.x*7.8125)*0.0001
	within_the_viewport.scale = Vector2(percentsize, percentsize)
	# set the displaying scale
	percentsize = 1/percentsize
	display.scale = Vector2(percentsize, percentsize)
	display.size = Vector2(max(root_size.x, 1280), max(root_size.y, 720))
