extends "res://Scripts/Modules/Module.gd"
class_name Thruster

const base_thrust_vector: Vector3 = Vector3(0, 1, 0);

export var max_thrust: float = 10
export(float, 1) var thrust_level = 0

# Rate of propelant consumption in kg/second
export var max_propellant_rate: float = 0

#export (int, -1, 1, 1) var pitch_control_direction
#export (int, -1, 1, 1) var yaw_control_direction
#export (int, -1, 1, 1) var roll_control_direction
#export (int, -1, 1, 1) var vertical_control_direction
#export (int, -1, 1, 1) var lateral_control_direction
#export (int, -1, 1, 1) var axial_control_direction

onready var thrust_vector: Vector3 = transform.basis.xform(base_thrust_vector).normalized()

func set_thrust_level(new_thrust_level: float) -> void:
	thrust_level = new_thrust_level
	$ThrustVector.visible = thrust_level > 0

func get_thrust() -> float:
	return thrust_level * max_thrust;

func get_propellant_rate() -> float:
	return thrust_level * max_propellant_rate;

