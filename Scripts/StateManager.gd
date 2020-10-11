extends Node

# Manages all state and state history for combat.  Supports adding to history 
# rewinding to a previous time.  Other scripts read and write state based on 
# data required to fulfill the scripts function.  State is maintained as a 
# dictionary

# The amount of state history kept per turn
export var state_history_max_length = 10

# The number of seconds between state history
export var state_time_interval = 1

# An array of state dictionaries
var _state_history = []

# Pointer to current state
var _state_pointer = 0;

func _init():
	name = "StateManager"

# Initialize the state
func init_state(initial_state):
	_state_history.clear()
	_state_history.push_back(initial_state)
	_state_pointer = 0

# update state values for the current state.  Note that the initial state for
# the turn (index 0) cannot be updated
func update_state(state_key, state_part):
	if (_state_pointer > 0):
		_state_history[_state_pointer][state_key] = state_part
	else:
		print("Cannot change initial state")

# Returns a copy of the current state
func get_state():
	return _state_history[_state_pointer].duplicate(true)

# Advances state the specified number of steps.  If state_updated is true, clear
# state past the pointer.  If the pointer + the number of
# steps exceeds the current limit of state history (or the state has been 
# updated), then call the new_state_initializer function passing the index and 
# the previous state to compute the next state for each step
func advance(number_of_steps, state_updated, state_initializer_ref): 
	# Do not adavance beyond the maimum history length
	if _state_pointer + number_of_steps == state_history_max_length - 1:
		print("Cannot advance past state history limit")
	else:	
		if state_updated:
			# clear state from pointer forward
			_state_history.resize(_state_pointer + 1)
		for i in range(number_of_steps):
			# If the pointer is at the end of the state or if the state has been updated
			if _state_pointer == _state_history.size() - 1:
				_state_history.push_back(state_initializer_ref.call_func(_state_pointer, _state_history.back()))
			_state_pointer += 1

# Restores time and state to a time the specified number of steps before 
# current time.  
func rewind(number_of_steps): 
	if number_of_steps > _state_pointer:
		print("Cannot rewind past initial state")
	else:	
		_state_pointer -= number_of_steps

# Captures current time and state.  Makes it the new base state, which 
# cannot be changed. 
func save_state():
	# capture current state
	var current_state = _state_history.back().duplicate(true)
	_state_history.clear()
	_state_history.push_back(current_state)
	_state_pointer = 0


