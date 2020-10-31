extends Node

const StateManager = preload("res://Scripts/StateManager.gd")
const Motion = preload("res://Scripts/Motion.gd")

# State keys
const THRUSTER_CONTROL_GROUP_SETTINGS: String = "thruster_control_group_settings"

var _current_time_step: int = 0

var _active_spacecraft: Spacecraft
var _active_thrusters: Array

# next state for active spacecraft
onready var _active_next_state_func_ref: FuncRef = funcref(self, "_active_next_state")

# maps control inputs to thruster commands
onready var _flight_controller: FlightController = $FlightController

# simulates motion of spacecraft and munitions
onready var _motion: Motion = Motion.new()

# state manager for dead reckoned spacecraft and projectiles
onready var _dr_state_manager: StateManager = StateManager.new(funcref(self, "_dr_next_state"))

# state manager for autonomous munitions
onready var _am_state_manager: StateManager = StateManager.new(funcref(self, "_am_next_state"))

var _active_state_manager: StateManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_active_spacecraft($Spacecraft/TestSpacecraft)

func _set_active_spacecraft(spacecraft: Spacecraft):
	_active_spacecraft = spacecraft
	_motion.body_mass = _active_spacecraft.mass
	_motion.body_moment_of_inertia = _active_spacecraft.moment_of_inertia
	_attach_state_manager()
	_active_thrusters = spacecraft.thrusters
	_flight_controller.set_thrusters(_active_thrusters)
	($Camera as GimballedCamera).update_target(spacecraft)
	
func _attach_state_manager() -> void:
	_active_state_manager = StateManager.new(_active_next_state_func_ref)
	_active_state_manager.init_state(_active_next_state(0, {}))
	_active_spacecraft.add_child(_active_state_manager)

func _on_TurnControl_time_updated(time: int) -> void:
	var delta: int = time - _current_time_step
	if delta >= 0: 
		_advance(delta) 
	else:
		_rewind(abs(delta))
	
	_current_time_step = time

func _advance(delta: int) -> void:
	var state_updated = _flight_controller.settings_updated()
	
	# advance state for active spacecraft
	_active_state_manager.advance(delta, state_updated)
	if (!state_updated):
		_restore_active_state()
	
	# advance state for autonomous munitions
#	_am_state_manager.advance(delta, state_updated)
#	if (!state_updated):
#		_restore_am_state()
	
	# advance state for other spacecraft and projectiles
#	_dr_state_manager.advance(delta, state_updated)
#	_restore_dr_state()

func _rewind(delta: int) -> void:
	# restore state for active ship
	_active_state_manager.rewind(delta)
	_restore_active_state()
	
	# restore state for autonomous munitions
#	_am_state_manager.rewind(delta)
#	_restore_am_state()
#
#	# advance state for other spacecraft and projectiles
#	_dr_state_manager.rewind(delta)
#	_restore_dr_state()

# Determines next state for active spacecraft based on flight control settings
func _active_next_state(state_index: int, current_state: Dictionary) -> Dictionary:
	var new_state:Dictionary = {}
	# Get flight control settings and update state
	_store_thruster_control_settings(new_state)
	
	# Get thrust levels and update propellant levels and forces
	for thruster in _active_thrusters:
		var thrust: float = thruster.get_thrust()
		var propellant_rate: float = thruster.get_propellant_rate()
		# TODO Consume propellant and check for available propellant
		_motion.update_force(thruster.name, -1 * thruster.thrust_vector * thrust, thruster.transform.origin)
	
	# Advance physics for active ship
	new_state.motion = _motion.next_state(current_state.get("motion", _motion.init_state()))
	
	# move the active ship
	_move_body(_active_spacecraft, new_state.motion.position, new_state.motion.rotation_basis())
	
	# Advance physics for other ships and projectiles
	return new_state;

# Determines next state for autonomous munitions
func _am_next_state(state_index: int, current_state: Dictionary) -> void:
	pass;

# Determines next state for projectiles and other spacecraft
func _dr_next_state(state_index: int, current_state: Dictionary) -> void:
	pass;

# Moves the body (spacecraft or projectile)
func _move_body(body: Spatial, position: Vector3, orientation: Basis) -> void:
	body.transform.origin = position
	body.transform.basis = orientation

# Restore state of active spacecraft
func _restore_active_state():
	var current_state = _active_state_manager.get_state();
	
	# Restore flight control settings from state
	_restore_thruster_control_settings(current_state[THRUSTER_CONTROL_GROUP_SETTINGS])
	
	# Restore thrust levels from state
	
	# Restore propellant levels from state
	
	# Restore position and orientation for active spacecraft
	_move_body(_active_spacecraft, current_state.motion.position, current_state.motion.rotation_basis())

# Restore state for autonomous munitions
func _restore_am_state() -> void:
	pass

# Restore state for projectiles and other spacecraft
func _restore_dr_state() -> void:
	pass

func _store_thruster_control_settings(new_state):
	new_state[THRUSTER_CONTROL_GROUP_SETTINGS] = _flight_controller.get_thruster_control_group_settings()

func _restore_thruster_control_settings(settings):
	_flight_controller.set_thruster_control_group_settings(settings)
