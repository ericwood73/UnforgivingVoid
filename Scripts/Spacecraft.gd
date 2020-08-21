extends RigidBody

# Note that Godot calculates moment of intertia for a box collider as 1/12M*(a^2 + b^2)
# Where a and b are the extents of the other axis.  So Ix = 1/12M*(y^2 + z^2)


export var velocity = Vector3(0, -1, 0)
export var base_mass = 500 # 1000's of kilograms
export var base_moment_inertia = 500 * 40^2

# Do not access these directly
var _module_mass = -1
var _module_moment_of_inertia = -1

var thrust_level = 0
var max_thrust = 100

var thruster_vectors = {}
var thruster_locations = {}
var base_thruster_vector = Vector3(0, 1, 0);
var thrust_forces = []

func _ready():
	# Since these don't change, do this once on ready
	get_thruster_vectors_and_locations()
	print(thruster_vectors)
	print(thruster_locations)

func _integrate_forces(state):
	thrust_forces = get_thrust_forces()
	for thrust_force in thrust_forces:
		print(thrust_force)
		print(state.inverse_inertia)
		state.add_force(thrust_force.vector, thrust_force.location)

func get_thruster_vectors_and_locations():
	var thruster_nodes = self.get_node("Modules/Thrusters")
	for thruster_node in thruster_nodes.get_children():
		thruster_vectors[thruster_node] = get_thruster_vector(thruster_node)
		thruster_locations[thruster_node] = get_thruster_location(thruster_node)

func get_thruster_vector(thruster_node):
	# Thurster vector is base vector with the thruster rotation transform applied
	return thruster_node.transform.basis.xform(base_thruster_vector)

func get_thruster_location(thruster_node):
	# Thurster location is a vector from the rb origin to the thruster in world coordinates
	return thruster_node.get_global_transform().origin - get_global_transform().origin

func get_thrust_forces():
	var updated_thrust_forces = []
	var thruster_nodes = self.get_node("Modules/Thrusters")
	for thruster_node in thruster_nodes.get_children():
		updated_thrust_forces.append({
			"vector": thruster_node.get_thrust() * thruster_vectors[thruster_node] * -1,
			"location": thruster_locations[thruster_node]
		})
	return updated_thrust_forces

func load_modules(json):
	pass
		





