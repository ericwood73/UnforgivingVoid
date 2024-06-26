extends Node
class_name FlightController

# Used to determine if a thruster contributes to an attitude change or translation
const THRESHOLD: float = 0.1
const POS: String = "POS"
const NEG: String = "NEG"
const PITCH: String = "pitch"
const YAW: String = "yaw"
const ROLL: String = "roll"
const VERTICAL: String = "vertical"
const LATERAL: String = "lateral"
const AXIAL: String = "axial"
const NULL_DICTIONARY: Dictionary = {}

var _thruster_control_group_settings: SixDOF = SixDOF.new()

var _settings_updated: bool = false;

# Map of thuster name to dictionary containing thruster, and a list of control 
# group, direction tuples
var _thruster_allocations: Dictionary = {}

func _ready() -> void:
	add_to_group(Constants.THRUSTER_CONTROL_GROUP_SETTINGS_GROUP_NAME)

func set_thrusters(thrusters: Array) -> void:
	# loop over thrusters.  Determine moment about each axis.  If absolute value
	# of moment is greater than threshold, thruster contributes to attitude
	# adjustment about that axis.  Similarly if absolute value of thrust vector 
	# componentis greater than threshold, thruster contributes to translation 
	# along that axis. 
	for thruster in thrusters:
		# Thrust force is opposite vector
		var thrust_force_vector: Vector3 = thruster.thrust_vector * -1
		var moment = thruster.transform.origin.cross(thrust_force_vector)
		_add_thruster_allocation(thruster, PITCH, moment.x)
		_add_thruster_allocation(thruster, YAW, moment.y)
		_add_thruster_allocation(thruster, ROLL, moment.z)
		_add_thruster_allocation(thruster, LATERAL, thrust_force_vector.x)
		_add_thruster_allocation(thruster, VERTICAL, thrust_force_vector.y)
		_add_thruster_allocation(thruster, AXIAL, thrust_force_vector.z)

func get_thruster_control_group_settings() -> SixDOF:
	# Return a copy to prevent modification
	return _thruster_control_group_settings.clone()

func set_thruster_control_group_settings(settings: SixDOF):
	_thruster_control_group_settings = settings
	_set_all_thruster_levels()
	_update_group()

# Indicates whether settings have been updated since the last call to this method
func settings_updated() -> bool:
	if _settings_updated:
		_settings_updated = false
		return true
	else:
		return false

func _update_group() -> void:
	# Return a copy to prevent modification
	get_tree().call_group(Constants.THRUSTER_CONTROL_GROUP_SETTINGS_GROUP_NAME, Constants.ON_THRUSTER_CONTROL_GROUP_SETTINGS_CHANGED, get_thruster_control_group_settings(), false)

func _add_thruster_allocation(thruster, control_group, value) -> void:
	var thruster_allocation: Dictionary = _thruster_allocations.get(thruster.name, NULL_DICTIONARY)
	if thruster_allocation == NULL_DICTIONARY:
		thruster_allocation = {
			thruster = thruster,
			control_groups = []
		}
		_thruster_allocations[thruster.name] = thruster_allocation
		
	if THRESHOLD < value:
		thruster_allocation.control_groups.push_back({
			control_group_name = control_group,
			direction = POS
		})
	elif -1 * THRESHOLD > value: 
		thruster_allocation.control_groups.push_back({
			control_group_name = control_group,
			direction = NEG
		})

func _set_all_thruster_levels() -> void:
	# loop over each thruster.  Set thrust level equal to percentage of max level
	# for each attitude change and translation control the thruster contributes 
	for thruster_allocation in _thruster_allocations.values():
		_set_thrust_levels(thruster_allocation)

# Set the thrust level for each thruster based on the control group settings and 
# allocation
func _set_thrust_levels(thruster_allocation) -> void:
	var thrust_level: float = 0
	for control_group in thruster_allocation.control_groups:
		# For each control group allocated to the thruster, check the control
		# group setting.  If it is not zero and the direction is aligned with 
		# the thruster, then command the thruster to fire at a level which is the 
		# greater of the current level and the setting.  This ensures that the 
		# thruster is commanded to the highest level corresponding to a control 
		# group to which it is allocated.
		var setting: float = _thruster_control_group_settings.get(control_group.control_group_name)
		var direction: String = control_group.direction
		match (control_group.control_group_name):
			PITCH:
				thrust_level = max(thrust_level, _get_thrust_level_setting(setting, direction, POS))
			YAW:
				# Negative yaw setting is left yaw which is a positive yaw rotation and 
				# uses yaw POS thrusters
				thrust_level = max(thrust_level, _get_thrust_level_setting(setting, direction, NEG))
			ROLL:
				# Negative roll setting is left roll which is a positive roll rotation and 
				# uses roll POS thrusters
				thrust_level = max(thrust_level, _get_thrust_level_setting(setting, direction, NEG))
			VERTICAL:
				thrust_level = max(thrust_level, _get_thrust_level_setting(setting, direction, POS))
			LATERAL:
				thrust_level = max(thrust_level, _get_thrust_level_setting(setting, direction, POS))
			AXIAL:
				# Positive axial setting is forward which is a negative z translation 
				thrust_level = max(thrust_level, _get_thrust_level_setting(setting, direction, NEG))
		thruster_allocation.thruster.set_thrust_level(thrust_level)

func _get_thrust_level_setting(control_group_setting, control_group_direction, control_group_pos_direction) -> float:
	if control_group_setting > 0 && control_group_direction == control_group_pos_direction:
		return abs(control_group_setting)
	elif control_group_setting < 0 && control_group_direction != control_group_pos_direction:
		return abs(control_group_setting)
	else:
		return 0.0

func on_thruster_control_group_settings_changed(updated_settings, user_input) -> void:
	if user_input:
		_thruster_control_group_settings = updated_settings
		_set_all_thruster_levels()
		_settings_updated = true

