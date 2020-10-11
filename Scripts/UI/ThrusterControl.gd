extends HSlider

export(String, "pitch", "yaw", "roll", 
			   "vertical", "lateral", "axial") var thrust_control_group_name

export(String) var increase_action
export(String) var decrease_action

signal thruster_control_setting_changed(value)

func _gui_input(event):
	if (event is InputEventMouseButton) && !event.pressed && (event.button_index == BUTTON_LEFT):
		_emit_control_setting_changed()

func _input(event):
	# Look for action press
	if event.is_action_released(increase_action) && value < max_value:
		value += step
		_emit_control_setting_changed()
	elif event.is_action_released(decrease_action) && value > min_value:
		value -= step
		_emit_control_setting_changed()

func _emit_control_setting_changed():
	emit_signal("thruster_control_setting_changed", value)


