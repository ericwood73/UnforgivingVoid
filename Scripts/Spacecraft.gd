extends Spatial
class_name Spacecraft

# Note that Godot calculates moment of intertia for a box collider as 1/12M*(a^2 + b^2)
# Where a and b are the extents of the other axis.  So Ix = 1/12M*(y^2 + z^2)
export var mass = 100 #kilograms
export var moment_of_inertia = Vector3(41.67, 41.67, 16.67)

# Do not access these directly
var _module_mass = -1
var _module_moment_of_inertia = -1

#var thruster_vectors = {}
#var thruster_locations = {}
#
#var thrust_forces = []

onready var thrusters = $Modules/Thrusters.get_children()

#func _integrate_forces(state):
#	thrust_forces = get_thrust_forces()
#	for thrust_force in thrust_forces:
#		state.add_force(thrust_force.vector, thrust_force.location)

#func get_thrusters():
#	return self.get_node("Modules/Thrusters").get_children()

#func get_thruster_location(thruster_node):
#	# Thurster location is a vector from the center of mass to the thruster in body coordinates
#	return thruster_node.transform.origin - transform.origin
#
#func get_thrust_forces():
#	var updated_thrust_forces = []
#	var thruster_nodes = self.get_node("Modules/Thrusters")
#	for thruster_node in thruster_nodes.get_children():
#		var thrust_vector = thruster_vectors[thruster_node] * -1
#		thruster_node.set_vector(thrust_vector * -1)
#		updated_thrust_forces.append({
#			"vector": thruster_node.get_thrust() * thrust_vector,
#			"location": thruster_locations[thruster_node]
#		})
#	return updated_thrust_forces

func load_modules(json):
	pass
		





