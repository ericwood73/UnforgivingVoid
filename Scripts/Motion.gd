extends Object
class_name Motion

const NULL_DICTIONARY: Dictionary = {}

# Provides simulation of linear and angular motion for a body. All positions 
# calculated are the position of the center of mass.

export(float) var body_mass = 0

# Center of mass in body coordinates relative to body origin
#export(Vector3) var body_mass_center

# Moments of inertia about body axes
export(Vector3) var body_moment_of_inertia

# Object to attach motion to
var body: Spatial

# Dictionary of force generators.  Keys are genrator id, value is force with vector
# and location in body coordinates and rotation.
var _force_generators: Dictionary = {}

func clear_forces() -> void:
	_force_generators = {}

# updates existing force generators or adds new force generators if a generator 
# with the specific key does not exist.  Force is dictionary with vector and 
# location in body coordinates and rotation
func update_force(force_generator_key: String, vector: Vector3, location: Vector3) -> void: 
	var force_generator: Dictionary = _force_generators.get(force_generator_key, NULL_DICTIONARY)
	if force_generator == NULL_DICTIONARY:
		force_generator = {
			force = vector,
			location = location
		}
		_force_generators[force_generator_key] = force_generator
	else:
		force_generator.force = vector
		force_generator.location = location

func init_state() -> State: 
	return State.new(body_mass, body_moment_of_inertia)

func next_state(state: State) -> State:
	var total_force_and_torque: Dictionary = _integrate_forces()
	var next_state: State = State.new(body_mass, body_moment_of_inertia)
	# Change in linear and angular momentum are equal to force and torque repsectively
	next_state.linear_momentum = state.linear_momentum + total_force_and_torque.force
	next_state.angular_momentum = state.angular_momentum + total_force_and_torque.torque
	var linear_velocity: Vector3 = next_state.linear_velocity()
	next_state.position = Vector3(state.position.x + linear_velocity.x,
								  state.position.y + linear_velocity.y,
								  state.position.z + linear_velocity.z)
	var q: Quat = state.rotation_quat
	var qdot: Quat = next_state.angular_velocity_quat()
	next_state.rotation_quat = Quat(q.x + qdot.x, q.y + qdot.y, q.z + qdot.z,
									q.w + qdot.w) 
	return next_state

#func _ready():
#	body = get_parent()
#	init_state(0,0,0,0)
#	_force_generators.f1 = {
#		force = Vector3(10,0,0),
#		location = Vector3(0,0,-1)
#	}
#	_force_generators.f2 = {
#		force = Vector3(0,0,-100),
#		location = Vector3(0,0,1)
#	}
#	advance(1)
#	advance(1)
#	advance(1)
#	advance(1)
#	advance(1)
#	rewind(3)
#	_force_generators.f1 = {
#		force = Vector3(10,0,0),
#		location = Vector3(0,0,-1)
#	}
#	advance(3)

func _integrate_forces() -> Dictionary:
	var total_force: Vector3 = Vector3()
	var total_torque: Vector3 = Vector3()
	for fg in _force_generators.values():
		total_force += fg.force
		total_torque += fg.location.cross(fg.force)
		
	print("  force: ", total_force)
	print("  torque: ", total_torque)
	
	return {
		force = total_force,
		torque = total_torque
	}

class State:
	var mass: float
	var inertia: Basis
	
	func _init(body_mass: float, body_inertia: Vector3):
		mass = body_mass
		inertia = Basis(Vector3(body_inertia.x, 0, 0),
						Vector3(0, body_inertia.y, 0),
						Vector3(0, 0, body_inertia.z))
	
	# Linear momentum in world space
	var linear_momentum: Vector3 = Vector3()
	
	# Position in world space
	var position: Vector3 = Vector3()
	
	# Angular momentum as a vector in global space that describes the axis of 
	# rotation and magnitude describes the rotational speed in degrees per second
	var angular_momentum: Vector3 = Vector3()
	
	var rotation_quat: Quat = Quat()
	
	# Rotation expressed as a basis (3x3 rotation matrix which describes the 
	# orienttion of the body x, y, and z axes) using vectors in gloabl 
	# coordinates
	func rotation_basis() -> Basis:
		return Basis(rotation_quat.normalized())
	
	func linear_velocity() -> Vector3:
		return linear_momentum/mass
	
	func inverse_inertia() -> Basis: 
		var rotation = rotation_basis()
		return rotation * inertia.inverse() * rotation.transposed()
	
	func angular_velocity() -> Vector3: 
		return  inverse_inertia()*angular_momentum
	
	func angular_velocity_quat() -> Quat:
		var omega: Vector3 = angular_velocity();
		var q: Quat = rotation_quat;
		return Quat(.5 * (omega.x * q.w + omega.y * q.z - omega.z * q.y),
					.5 * (omega.y * q.w + omega.z * q.x - omega.x * q.z),
					.5 * (omega.z * q.w + omega.x * q.y - omega.y * q.x),
					-.5 * (omega.x * q.x + omega.y * q.y + omega.z * q.z))

	
	
