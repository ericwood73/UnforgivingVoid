extends "res://Scripts/Modules/Module.gd"

export var max_thrust = 10
export(float, 1) var thrust_level = 0

func get_thrust():
	return thrust_level * max_thrust;
	
