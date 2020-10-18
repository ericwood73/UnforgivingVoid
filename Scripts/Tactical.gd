extends Node

const StateManager = preload("res://Scripts/StateManager.gd")
const Motion = preload("res://Scripts/Motion.gd")

# State keys
const THRUSTER_CONTROL_GROUP_SETTINGS = "thruster_control_group_settings"

var current_time_step = 0

var active_spacecraft 
var active_state
var active_thrusters

onready var _next_state_func_ref = funcref(self, "_next_state")
onready var flight_controller = $FlightController
onready var motion = Motion.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	_attach_state_managers()
	_set_active_spacecraft($Combatants/TestSpacecraft)

func _set_active_spacecraft(spacecraft):
	active_spacecraft = spacecraft
	active_state = spacecraft.get_node("StateManager")
	active_thrusters = spacecraft.thrusters
	flight_controller.set_thrusters(active_thrusters)
	$Camera.update_target(spacecraft)

func _attach_state_managers():
	for combatant in $Combatants.get_children():
		_attach_state_manager(combatant)

func _attach_state_manager(combatant):
	var state_manager = StateManager.new()
	state_manager.init_state(_next_state(0,{}))
	combatant.add_child(state_manager)

func _on_TurnControl_time_updated(time):
	var delta = time - current_time_step
	if delta >= 0: 
		_advance(delta) 
	else:
		_rewind(abs(delta))
	
	current_time_step = time

func _advance(delta):
	var state_updated = flight_controller.settings_updated()
	active_state.advance(delta, state_updated, _next_state_func_ref)
	
	if (!state_updated):
		_restore_state()

func _rewind(delta):
	active_state.rewind(delta)
	_restore_state()
	
	# Update the flight control settings
#	active_thrust_controller.update_control_settings(active_state.get_state("flight_control_settings"))
	
	# update thrust levels
#	for thruster in $Spacecraft/Thrusters:
#		thruster.update_thrust_level(delta)
#		$Spacecraft/TurnBasedPhysics.update_force(thruster.name, 
#												  _get_thrust_vector(thruster), 
#												  _get_thruster_location(thruster))
#		if advance:
#			$Spacecraft/TurnBasedPhysics.advance(delta)
#		else:
#			$Spacecraft/TurnBasedPhysics.rewind(delta)

func _next_state(state_index, current_state):
	var new_state = {}
	# Get flight control settings and update state
	_store_thruster_control_settings(new_state)
	
	# Get thrust levels and update state
	
	# Get propellant levels (updated by thrusters) and update state
	
	# Update forces in physics
	
	# Advance physics for active ship
	
	# Advance physics for other ships and projectiles
	return new_state;


# Moves the body (spacecraft or projectile)
func _move_body(body, position, orientation):
	body.transform.origin = position
	body.transform.basis = orientation

func _get_thrust_vector(thruster):
	return thruster.thrust_vector * thruster.get_thrust()

func _get_thruster_location(thruster):
	# Thurster location is a vector from the center of mass to the thruster in body coordinates
	return thruster.transform.origin - $Spacecraft.transform.origin	

func _restore_state():
	var current_state = active_state.get_state();
	
	# Restore flight control settings from state
	_restore_thruster_control_settings(current_state[THRUSTER_CONTROL_GROUP_SETTINGS])
	
	# Restore thrust levels from state
	
	# Restore propellant levels from state
	
	# Restore position and orientation for active spacecraft
	
	# Restore position and orientation for other combatants and projectiles

func _store_thruster_control_settings(new_state):
	new_state[THRUSTER_CONTROL_GROUP_SETTINGS] = flight_controller.get_thruster_control_group_settings()

func _restore_thruster_control_settings(settings):
	flight_controller.set_thruster_control_group_settings(settings)
