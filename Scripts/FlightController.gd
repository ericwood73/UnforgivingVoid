extends Node

var _thruster_control_settings = SixDOF.new()

var _settings_updated = false;

func _ready():
	add_to_group(Constants.THRUSTER_CONTROL_SETTINGS_GROUP_NAME)

func get_thruster_control_settings():
	# Return a copy to prevent modification
	return _thruster_control_settings.clone()

func set_thruster_control_settings(settings):
	_thruster_control_settings = settings
	_update_group()

# Indicates whether settings have been updated since the last call to this method
func settings_updated():
	if _settings_updated:
		_settings_updated = false
		return true
	else:
		return false

func _update_group():
	# Return a copy to prevent modification
	get_tree().call_group(Constants.THRUSTER_CONTROL_SETTINGS_GROUP_NAME, Constants.ON_THRUSTER_CONTROL_SETTINGS_CHANGED, get_thruster_control_settings(), false)
	
func on_thruster_control_settings_changed(updated_settings, user_input):
	if user_input:
		_thruster_control_settings = updated_settings
		_settings_updated = true
			
