extends Node

# Manages all state and state history for combat.  Supports adding to history 
# rewinding to a previous time.  Other scripts read and write state based on 
# data required to fulfill the scripts function.  State is maintained as a 
# dictionary

# The amount of state history kept per turn
export var state_history_max_length: int = 10

# The number of seconds between state history
export var state_time_interval: int = 1

# Each element is the state for a time
var _state_history = []

# Pointer to current state
var _state_pointer: int = 0;

var _state_initializer_ref: FuncRef

func _init(state_initializer_ref: FuncRef):
	name = "StateManager"
	_state_initializer_ref = state_initializer_ref

# Initialize the state
func init_state(initial_state: Dictionary):
	_state_history.clear()
	_state_history.push_back(initial_state)
	_state_pointer = 0;

# update state values for the current state.  Note that the initial state for
# the turn (index 0) cannot be updated
func update_state(state_key, state_part):
	if (_state_pointer > 0):
		_state_history[_state_pointer][state_key] = state_part
	else:
		print("Cannot change initial state")

# Returns a copy of the current state
func get_state() -> Dictionary:
	return _state_history[_state_pointer].duplicate(true)

# Advances state the specified number of steps.  If state_updated is true, clear
# state past the pointer.  If the pointer + the number of
# steps exceeds the current limit of state history (or the state has been 
# updated), then call the new_state_initializer function passing the index and 
# the previous state to compute the next state for each step
func advance(number_of_steps: int, state_updated: bool): 
	# Do not adavance beyond the maimum history length
	if _state_pointer + number_of_steps > state_history_max_length - 1:
		print("Cannot advance past state history limit")
	else:	
		if state_updated && _state_history.size() > 1:
			# clear state from pointer forward
			_state_history.resize(_state_pointer + 1)
		for i in range(number_of_steps):
			# If the pointer is at the end of the state or if the state has been updated
			if _state_pointer == _state_history.size() - 1:
				_state_history.push_back(_state_initializer_ref.call_func(_state_pointer, _state_history.back()))
			_state_pointer += 1
	print("state pointer - ", _state_pointer)

# Restores time and state to a time the specified number of steps before 
# current time.  
func rewind(number_of_steps: int): 
	if _state_pointer - number_of_steps < 0:
		print("Cannot rewind past initial state")
	else:	
		_state_pointer -= number_of_steps
	print("state pointer - ", _state_pointer)

# Captures current time and state.  Makes it the new base state, which 
# cannot be changed. 
func save_state():
	# capture current state
	var current_state = _state_history.back().duplicate(true)
	_state_history.clear()
	_state_history.push_back(current_state)
	_state_pointer = 0
	



