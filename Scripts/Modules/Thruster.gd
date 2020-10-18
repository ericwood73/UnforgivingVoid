extends "res://Scripts/Modules/Module.gd"

const base_thrust_vector = Vector3(0, 1, 0);

export var max_thrust = 10
export(float, 1) var thrust_level = 0

# Rate of propelant consumption in kg/second
export var max_propellant_rate = 0

#export (int, -1, 1, 1) var pitch_control_direction
#export (int, -1, 1, 1) var yaw_control_direction
#export (int, -1, 1, 1) var roll_control_direction
#export (int, -1, 1, 1) var vertical_control_direction
#export (int, -1, 1, 1) var lateral_control_direction
#export (int, -1, 1, 1) var axial_control_direction

onready var thrust_vector = transform.basis.xform(base_thrust_vector).normalized()

func get_thrust():
	return thrust_level * max_thrust;

