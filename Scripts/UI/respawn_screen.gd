extends CenterContainer

signal respawn

func _on_respawn_pressed() -> void:
	#emit_signal("respawn")
	# I don't have time for this
	get_tree().reload_current_scene()

func set_enemy_sounds(volume : float = 1.0):
	AudioServer.set_bus_volume_db(3, linear_to_db(volume))
