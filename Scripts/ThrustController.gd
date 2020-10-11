extends Node

# Coontrols thrust output from individual thrusters based on control settings
# Proportions thrust according to a Thrust Allocation Table

var _pitch_setting = 0
var _yaw_setting = 0
var _roll_setting = 0
var _vertical_setting = 0
var _lateral_setting = 0
var _axial_setting = 0

var thrusters

var control_directions = {}

func _register_control(control_group_name, control_direction):
	control_directions[control_group_name] = control_direction;
	add_to_group(control_group_name)

func _init_controls():
	if pitch_control_direction != 0:
		_register_control("pitch_control", pitch_control_direction)
	if yaw_control_direction != 0: 
		_register_control("yaw_control", yaw_control_direction)
	if roll_control_direction != 0: 
		_register_control("roll_control", roll_control_direction)
	if vertical_control_direction != 0: 
		_register_control("vertical_control", vertical_control_direction)
	if lateral_control_direction != 0: 
		_register_control("lateral_control", lateral_control_direction)
	if axial_control_direction != 0: 
		_register_control("axial_control", axial_control_direction)

func _ready():
	_init_controls()

func _ready():
	thrusters = get_parent().get_child(Thrusters).get_children()

func set_pitch(pitch_setting):
	_pitch_setting = pitch_setting
	_update_thruster_levels()
	
func set_yaw(yaw_setting):
	_yaw_setting = yaw_setting
	_update_thruster_levels()
	
func set_roll(roll_setting):
	_roll_setting = roll_setting
	_update_thruster_levels()
	
func set_vertical(vertical_setting):
	_vertical_setting = vertical_setting
	_update_thruster_levels()
	
func set_lateral(lateral_setting):
	_lateral_setting = lateral_setting
	_update_thruster_levels()
	
func set_axial(axial_setting):
	_axial_setting = axial_setting
	_update_thruster_levels()				
	
func _update_thruster_levels():
	pass
