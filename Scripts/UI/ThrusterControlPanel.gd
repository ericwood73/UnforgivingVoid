extends Control

var thruster_control_settings = SixDOF.new()

onready var _pitch_control = $VBoxContainer/AttitudeControlGrid/PitchControl
onready var _yaw_control = $VBoxContainer/AttitudeControlGrid/YawControl
onready var _roll_control = $VBoxContainer/AttitudeControlGrid/RollControl
onready var _vertical_control = $VBoxContainer/TranslationControlGrid/VerticalControl
onready var _lateral_control = $VBoxContainer/TranslationControlGrid/LateralControl
onready var _axial_control = $VBoxContainer/TranslationControlGrid/AxialControl


func _ready():
	add_to_group(Constants.THRUSTER_CONTROL_SETTINGS_GROUP_NAME)

func _update_group():
	# Return a copy of settings to prevent modification
	get_tree().call_group(Constants.THRUSTER_CONTROL_SETTINGS_GROUP_NAME, Constants.ON_THRUSTER_CONTROL_SETTINGS_CHANGED, thruster_control_settings.clone(), true)

func on_thruster_control_settings_changed(thruster_control_settings, user_input):
	if !user_input:
		_pitch_control.value = thruster_control_settings.pitch()
		_yaw_control.value = thruster_control_settings.yaw()
		_roll_control.value = thruster_control_settings.roll()
		_vertical_control.value = thruster_control_settings.vertical()
		_lateral_control.value = thruster_control_settings.lateral()
		_axial_control.value = thruster_control_settings.axial()

func _on_thruster_control_setting_changed(value):
	thruster_control_settings.pitch(_pitch_control.value)
	thruster_control_settings.yaw(_yaw_control.value)
	thruster_control_settings.roll(_roll_control.value)
	thruster_control_settings.vertical(_vertical_control.value)
	thruster_control_settings.lateral(_lateral_control.value)
	thruster_control_settings.axial(_axial_control.value)
	_update_group()


